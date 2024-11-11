defmodule CosmicCoral.Record do
  @moduledoc """
  The record context, to manipulate entities in the database.
  """

  import Ecto.Query, warn: false
  alias CosmicCoral.Repo
  alias CosmicCoral.Entity
  alias CosmicCoral.Record

  @doc """
  Gets a single entity and returns it, `nil` if it doesn't exist.

  ## Examples

      iex> get_entity(123)
      %Entity{}

      iex> get_entity(456)
      nil

  """
  def get_entity(id) do
    Cachex.fetch(:cc_cache, id, fn id ->
      Repo.get(Record.Entity, id)
      |> Repo.preload([:attributes, :methods])
      |> case do
        nil -> {:ignore, nil}
        entity ->
          entity =
            entity
            |> cache_entity_attributes()
            |> Entity.new()

          {:commit, entity}
      end
    end)
    |> from_cache_entity()
  end

  @doc """
  Creates an entity.

  ## Examples

      iex> create_entity(%{field: value})
      {:ok, %Entity{}}

      iex> create_entity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entity(attrs \\ %{}) do
    %Record.Entity{}
    |> Record.Entity.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, entity} ->
        entity = Entity.new(entity)
        Cachex.put(:cc_cache, entity.id, entity)
        {:ok, entity}

      other -> other
    end
  end

  @doc """
  Set an entity attribute to any value.

  Arguments:

  * id (integer): the entity ID.
  * name (binary): the attribute's name to set (might exist).
  * value (any): the value to set.

  """
  @spec set_attribute(integer(), String.t(), any()) :: :ok | :invalid_entity
  def set_attribute(id, name, value) do
    case get_entity(id) do
      nil -> :invalid_entity
      entity -> set_entity_attribute(entity, name, value)
    end
  end

  @doc """
  Deletes an entity.

  ## Examples

      iex> delete_entity(5)
      {:ok, %Entity{}}

      iex> delete_entity(99)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entity(entity_id) do
    case Repo.get(Record.Entity, entity_id) do
      nil -> :error
      entity ->
        Repo.delete(entity)
        Cachex.del(:cc_cache, entity_id)
        :ok
    end
  end

  defp from_cache_entity({:ok, entity}), do: entity
  defp from_cache_entity({:commit, entity}), do: entity
  defp from_cache_entity({:ignore, nil}), do: nil

  defp cache_entity_attributes(%Record.Entity{attributes: attributes} = entity) when is_list(attributes) do
    for attribute <- attributes do
      Cachex.put(:cc_cache, {:attribute, entity.id, attribute.name}, attribute.id)
    end

    entity
  end

  defp cache_entity_attributes(%Record.Entity{} = entity), do: entity

  defp set_entity_attribute(%Entity{attributes: attributes} = entity, name, value) do
    case Map.fetch(attributes, name) do
      :error -> create_entity_attribute_value(entity, name, value)
      {:ok, former_value} ->
        set_entity_attribute_value(entity, name, value, former_value)
    end
  end

  defp create_entity_attribute_value(%Entity{} = entity, name, value) do
    attrs = %{entity_id: entity.id, name: name, value: :erlang.term_to_binary(value)}

    %Record.Attribute{}
    |> Record.Attribute.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, attribute} ->
        Cachex.put(:cc_cache, {:attribute, entity.id, attribute.name}, attribute.id)
        entity = %{entity | attributes: Map.put(entity.attributes, name, value)}
        Cachex.put(:cc_cache, entity.id, entity)
        entity

      error -> error
    end
  end

  defp set_entity_attribute_value(%Entity{} = entity, name, value, former) do
    case Cachex.get(:cc_cache, {:attribute, entity.id, name}) do
      {:ok, nil} -> create_entity_attribute_value(entity, name, value)
      {:ok, attribute_id} ->
        serialized = :erlang.term_to_binary(value)

        if :erlang.term_to_binary(former) != serialized do
          Repo.get(Record.Attribute, attribute_id)
          |> Record.Attribute.changeset(%{value: serialized})
          |> Repo.update()
        end

        entity = %{entity | attributes: Map.put(entity.attributes, name, value)}
        Cachex.put(:cc_cache, entity.id, entity)
        entity
    end
  end
end
