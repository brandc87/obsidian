defmodule Obsidian.Context.Characters do
  import Ecto.Query, except: [update: 2]

  alias Obsidian.{Repo, Schema}

  def list(%Schema.Account{id: account_id}) do
    Schema.Character
    |> where([c], c.account_id == ^account_id)
    |> Repo.all()
  end

  def create_character(account, attrs) do
    %Schema.Character{account: account}
    |> Schema.Character.changeset(attrs)
    |> Repo.insert()
  end
end
