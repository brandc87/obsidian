defmodule Obsidian.Auth do
  use ThousandIsland.Handler

  alias Obsidian.Context.Accounts

  require Logger

  @cmsg_auth_login 1280
  @cmsg_auth_create_account 1282

  @smsg_auth_create_account_success 1282
  @smsg_auth_create_account_error 1283

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
        <<@cmsg_auth_login::little-unsigned-16, _length::little-unsigned-16, packet::binary>>,
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
        <<@cmsg_auth_create_account::little-unsigned-16, _length::little-unsigned-16,
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

          reply = <<@smsg_auth_create_account_success::little-unsigned-16>>
          ThousandIsland.Socket.send(socket, reply)

          {:continue, state}

        {:error, _} ->
          Logger.error("AUTH REGISTER: #{username} FAILED")

          message = "Error creating account"

          reply =
            <<@smsg_auth_create_account_error::little-unsigned-16,
              4 + byte_size(message)::little-unsigned-16>> <>
              message

          ThousandIsland.Socket.send(socket, reply)

          {:continue, state}
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
