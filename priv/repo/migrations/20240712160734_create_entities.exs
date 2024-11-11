defmodule CosmicCoral.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    create table(:entities) do
      add :key, :text
      add :location_id, references(:entities, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:entities, [:location_id])
  end
end