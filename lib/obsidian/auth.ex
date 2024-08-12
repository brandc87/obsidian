defmodule Obsidian.Auth do
  use ThousandIsland.Handler

  alias Obsidian.Context.Accounts

  require Logger

  @cmd_auth_login 1280
  @cmd_auth_create_account 1282

  @impl ThousandIsland.Handler
  def handle_connection(_socket, state) do
    Logger.info("CLIENT CONNECTED")

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_close(_socket, _state) do
    Logger.info("CLIENT DISCONNECTED")
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmd_auth_login::little-unsigned-16, _length::little-unsigned-16, packet::binary>>,
        _socket,
        state
      ) do
    array =
      packet
      |> to_string()
      |> String.split("/")

    if length(array) == 2 do
      [username, password] = array
      Logger.info("CLIENT LOGIN: #{inspect(username)} - #{inspect(password)}")
    end

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmd_auth_create_account::little-unsigned-16, _length::little-unsigned-16,
          packet::binary>>,
        socket,
        state
      ) do
    data =
      packet
      |> to_string()
      |> String.split("/", parts: 5)

    if length(data) == 5 do
      [username, password, question, answer, referrer_code] = data

      %{
        username: username,
        password: password,
        security_question: question,
        security_answer: answer,
        referrer_code: referrer_code
      }
      |> Accounts.register_account()
      |> case do
        {:ok, account} ->
          Logger.info("AUTH REGISTER: #{account.username}")

          packet = <<1282::little-unsigned-16>>
          ThousandIsland.Socket.send(socket, packet)

          {:continue, state}

        {:error, _} ->
          Logger.error("CLIENT REGISTER: #{username}")

          {:close, state}
      end
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(<<opcode::little-unsigned-16, packet::binary>>, _socket, state) do
    Logger.error(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode, base: :hex)}) - #{inspect(packet)}"
    )

    {:continue, state}
  end
end
