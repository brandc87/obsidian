defmodule Obsidian.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false

      add :name, :citext, null: false
      add :gender, :integer, null: false
      add :job, :integer, null: false
      add :hair_style, :integer, null: false
      add :hair_colour, :integer, null: false
      add :face_style, :integer, null: false
      add :level, :integer, null: false
      add :experience, :bigint, null: false

      add :frozen_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:characters, [:account_id])
    create unique_index(:characters, [:name])
  end
end
