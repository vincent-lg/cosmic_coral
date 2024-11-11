defmodule CosmicCoral.Repo do
  use Ecto.Repo,
    otp_app: :cosmic_coral,
    adapter: Ecto.Adapters.SQLite3
end
