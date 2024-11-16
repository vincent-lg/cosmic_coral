defmodule CosmicCoral.Record.Entity do
  use Ecto.Schema
  import Ecto.Changeset
  alias CosmicCoral.Record.Entity

  schema "entities" do
    belongs_to :location, Entity, foreign_key: :location_id
    belongs_to :parent, Entity, foreign_key: :parent_id
    has_many :attributes, CosmicCoral.Record.Attribute
    has_many :methods, CosmicCoral.Record.Method
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:location_id, :parent_id])
    |> validate_required([])
  end
end
