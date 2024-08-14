defmodule Obsidian.Auth do
  use ThousandIsland.Handler

  alias Obsidian.Context.Accounts

  require Logger

  @cmsg_auth_login 1280
  @cmsg_auth_create_account 1282
  @cmsg_auth_start_game 1286
  @cmsg_auth_logout 1297

  @smsg_auth_login_success 1280
  @smsg_auth_login_error 1281
  @smsg_auth_create_account_success 1282
  @smsg_auth_create_account_error 1283
  @smsg_auth_start_game_success 1286
  @smsg_auth_start_game_error 1287
  @smsg_auth_logout_success 1288

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_auth_login::little-unsigned-16, _length::little-unsigned-16, packet::binary>>,
        socket,
        state
      ) do
    array =
      packet
      |> to_string()
      |> String.split("/", parts: 2)

    if length(array) == 2 do
      [username, password] = array

      if account = Accounts.get_account_by_username_and_password(username, password) do
        Logger.debug("AUTH LOGIN: #{account.username} logged in.")
        state = state |> Map.put(:account, account)

        # TODO: Change this from hard coded.
        server_list =
          [
            %{
              public_address_ip: "192.168.20.24",
              public_address_port: 8701,
              server_name: "Obsidian"
            }
          ]
          |> Enum.map(fn server ->
            "#{server.public_address_ip}:#{server.public_address_port}/#{server.server_name}"
          end)
          |> Enum.join("\n")

        reply =
          <<@smsg_auth_login_success::little-unsigned-16,
            4 + byte_size(server_list)::little-unsigned-16>> <>
            server_list

        ThousandIsland.Socket.send(socket, reply)

        {:continue, state}
      else
        Logger.debug("AUTH LOGIN: #{username} failed logged in.")

        message = "Wrong username or password"

        reply =
          <<@smsg_auth_login_error::little-unsigned-16,
            4 + byte_size(message)::little-unsigned-16>> <>
            message

        ThousandIsland.Socket.send(socket, reply)

        {:continue, state}
      end
    else
      Logger.warning("AUTH LOGIN: Invalid request")

      {:close, state}
    end
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
          Logger.debug("AUTH REGISTER: #{account.username}")

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
    else
      Logger.warning("AUTH REGISTER: Invalid request")

      {:close, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_auth_start_game::little-unsigned-16, _length::little-unsigned-16,
          packet::binary>>,
        socket,
        state
      ) do
    data =
      packet
      |> to_string()
      |> String.split("/", parts: 2)

    if Map.has_key?(state, :account) and length(data) == 2 do
      Logger.debug("AUTH START GAME: #{state.account.username}")

      # TODO: Check for valid server in server list.

      ticket = Obsidian.TicketGenerator.generate_ticket()

      ticket_data =
        [
          ticket,
          state.account.username,
          "",
          "",
          ""
        ]
        |> Enum.join(";")

      Obsidian.TicketSender.send_ticket({127, 0, 0, 1}, 6678, ticket_data)

      reply =
        <<@smsg_auth_start_game_success::little-unsigned-16,
          4 + byte_size(ticket)::little-unsigned-16>> <>
          ticket

      ThousandIsland.Socket.send(socket, reply)

      {:continue, state}
    else
      Logger.warning("AUTH START GAME: Invalid request")

      message = "Error starting game"

      reply =
        <<@smsg_auth_start_game_error::little-unsigned-16,
          4 + byte_size(message)::little-unsigned-16>> <>
          message

      ThousandIsland.Socket.send(socket, reply)

      {:close, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_auth_logout::little-unsigned-16>>,
        socket,
        state
      ) do
    Logger.debug("AUTH LOGOUT: #{state.account.username}")

    state = state |> Map.delete(:account)

    message = "Successfully logged out"

    reply =
      <<@smsg_auth_logout_success::little-unsigned-16,
        4 + byte_size(message)::little-unsigned-16>> <>
        message

    ThousandIsland.Socket.send(socket, reply)

    {:close, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(<<opcode::little-unsigned-16, packet::binary>>, _socket, state) do
    Logger.warning(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode)}) - #{inspect(packet)}"
    )

    {:continue, state}
  end
end
