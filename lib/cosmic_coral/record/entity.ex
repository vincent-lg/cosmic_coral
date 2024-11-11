defmodule CosmicCoral.Record.Entity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entities" do
    field :key, :string
    field :location_id, :id
    has_many :attributes, CosmicCoral.Record.Attribute
    has_many :methods, CosmicCoral.Record.Method
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:key, :location_id])
    |> validate_required([])
  end
end
