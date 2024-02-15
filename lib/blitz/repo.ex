defmodule Blitz.Repo do
  use Ecto.Repo,
    otp_app: :blitz,
    adapter: Ecto.Adapters.Postgres
end
