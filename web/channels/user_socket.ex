defmodule CercleApi.UserSocket do
  use Phoenix.Socket

  alias CercleApi.{GuardianSerializer}

  ## Channels
  # channel "rooms:*", CercleApi.RoomChannel

  channel "contacts:*", CercleApi.ContactChannel
  channel "timeline_events:*", CercleApi.TimelineEventChannel
  channel "opportunities:*", CercleApi.OpportunityChannel
  channel "users:*", CercleApi.UserChannel
  channel "board:*", CercleApi.BoardChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    timeout: 45_000
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # def connect(_params, socket) do
  #   {:ok, socket}
  # end

  def connect(%{"token" => token}, socket) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case GuardianSerializer.from_token(claims["sub"]) do
          {:ok, user} ->
            {:ok, assign(socket, :current_user, user)}
          {:error, _reason} ->
            :error
        end
      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     CercleApi.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  #def id(_socket), do: nil

  #def connect(%{"token" => token}, socket) do
  #  # max_age: 1209600 is equivalent to two weeks in seconds
  #  case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
  #    {:ok, user_id} ->
  #      {:ok, assign(socket, :user, user_id)}
  #    {:error, reason} ->
  #      :error
  #  end
  #end
end
