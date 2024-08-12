defmodule Obsidian.Context.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Obsidian.{Repo, Schema.Account}

  ## Database getters

  @doc """
  Gets a account by username.

  ## Examples

      iex> get_account_by_username("my_user")
      %User{}

      iex> get_account_by_username("unknown_user")
      nil

  """
  def get_account_by_username(username) when is_binary(username) do
    Repo.get_by(Account, username: username)
  end

  @doc """
  Gets a account by username and password.

  ## Examples

      iex> get_account_by_username_and_password("my_user", "correct_password")
      %Account{}

      iex> get_account_by_username_and_password("my_user", "invalid_password")
      nil

  """
  def get_account_by_username_and_password(username, password)
      when is_binary(username) and is_binary(password) do
    account = Repo.get_by(Account, username: username)
    if Account.valid_password?(account, password), do: account
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  ## Account registration

  @doc """
  Registers a account.

  ## Examples

      iex> register_account(%{field: value})
      {:ok, %Account{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end
end
