defmodule MembraneExample.Repo do
  use Ecto.Repo,
    otp_app: :membrane_example,
    adapter: Ecto.Adapters.Postgres
end
