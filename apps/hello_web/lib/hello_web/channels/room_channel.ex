defmodule HelloWeb.RoomChannel do
  alias HelloWeb.Registry.Room, as: RoomRegistry

  use HelloWeb, :channel

  intercept(~w(message))

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      current_user_id = payload["current_user_id"]
      socket = assign(socket, :current_user_id, current_user_id)
      {:ok, _} = Registry.register(RoomRegistry, {current_user_id, __MODULE__}, [])
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_info({:message, message}, socket) do
    IO.inspect({__MODULE__, :message, message})
    broadcast_from(socket, "message", %{message: message})
    {:noreply, socket}
  end

  def handle_out("message", %{"message" => message}, socket) do
    IO.inspect({__MODULE__, %{"message" => message}})

    Registry.dispatch(
      RoomRegistry,
      {socket.assigns.current_user_id, HelloWeb.HelloLive},
      &for({pid, _} <- &1, do: send(pid, {:message, message}))
    )

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
