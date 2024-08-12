defmodule Obsidian.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:accounts) do
      add :username, :citext, null: false
      add :hashed_password, :string, null: false
      add :security_question, :string
      add :security_answer, :string
      add :referrer_code, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:username])
  end
end
