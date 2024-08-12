defmodule Obsidian.Repo do
  use Ecto.Repo,
    otp_app: :obsidian,
    adapter: Ecto.Adapters.Postgres
end
