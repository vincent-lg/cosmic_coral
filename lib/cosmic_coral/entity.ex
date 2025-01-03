defmodule CosmicCoral.Entity do
  @moduledoc """
  A CosmicCoral entity with an ID, location, parent, attributes and methods.

  See `CosmicCoral.Record` for a context to manipulate the entity in database.
  """

  @enforce_keys [:id, :location_id]
  defstruct [:id, :parent_id, :location_id, key: nil, attributes: %{}, methods: %{}]

  @type t() :: %{
          id: integer(),
          key: binary(),
          parent_id: integer(),
          location_id: integer(),
          attributes: map(),
          methods: map()
        }

  @doc """
  Create an entity from a database record.
  """
  @spec new(struct()) :: t()
  def new(%CosmicCoral.Record.Entity{} = entity, key \\ nil) do
    %CosmicCoral.Entity{
      id: entity.id,
      key: key,
      parent_id: entity.parent_id,
      location_id: entity.location_id,
      attributes: new_attributes(entity.attributes),
      methods: new_methods(entity.methods)
    }
  end

  defp new_attributes(attributes) when is_list(attributes) do
    Map.new(attributes, fn attribute ->
      {attribute.name, :erlang.binary_to_term(attribute.value)}
    end)
  end

  defp new_attributes(_), do: %{}

  defp new_methods(methods) when is_list(methods) do
    Map.new(methods, fn method ->
      {method.name, method.value}
    end)
  end

  defp new_methods(_), do: %{}
end
