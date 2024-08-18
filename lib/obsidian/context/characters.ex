defmodule Obsidian.Context.Characters do
  import Ecto.Query, except: [update: 2]

  alias Obsidian.{Repo, Schema}

  def get_characters!(%Schema.Account{id: account_id}) do
    Schema.Character
    |> where([c], c.account_id == ^account_id)
    |> Repo.all()
  end

  def create(account, attrs) do
    %Schema.Character{account: account}
    |> Schema.Character.changeset(attrs)
    |> Repo.insert()
  end

  def get(%Schema.Account{id: account_id}, character_id) do
    case Repo.get_by(Schema.Character, account_id: account_id, id: character_id) do
      nil -> {:error, :character_not_found}
      character -> {:ok, character}
    end
  end

  def get(name) do
    case Repo.get_by(Schema.Character, name: name) do
      nil -> {:error, :character_not_found}
      character -> {:ok, character}
    end
  end

  def delete(%Schema.Character{} = character) do
    Repo.delete(character)
  end

  def character_exists?(name) do
    case get(name) do
      {:error, _} -> false
      _ -> true
    end
  end

  def at_character_limit?(%Schema.Account{id: account_id}) do
    case get_characters!(account_id) do
      characters when length(characters) >= 4 -> true
      _ -> false
    end
  end
end
