defmodule Obsidian.Schema.Character do
  use Ecto.Schema

  import Ecto.Changeset

  alias Obsidian.Schema

  @fields [
    :name,
    :gender,
    :job,
    :hair_style,
    :hair_colour,
    :face_style
  ]

  @optional_fields [
    :level,
    :experience,
    :frozen_at
  ]

  schema "characters" do
    belongs_to :account, Schema.Account

    field :name, :string
    field :gender, :integer
    field :job, :integer
    field :hair_style, :integer
    field :hair_colour, :integer
    field :face_style, :integer
    field :level, :integer, default: 1
    field :experience, :integer, default: 0

    field :frozen_at, :utc_datetime, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, @fields ++ @optional_fields)
    |> validate_required(@fields)
    |> unsafe_validate_unique(:name, Obsidian.Repo)
    |> unique_constraint(:name)
  end
end
