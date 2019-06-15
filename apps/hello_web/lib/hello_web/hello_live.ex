defmodule HelloWeb.HelloLive do
  alias HelloWeb.Registry.Room, as: RoomRegistry

  use Phoenix.LiveView

  def render(assigns), do: HelloWeb.HelloView.render("hello.html", assigns)

  def mount(%{current_user_id: current_user_id}, socket) do
    if connected?(socket),
      do: {:ok, _} = Registry.register(RoomRegistry, {current_user_id, __MODULE__}, [])

    socket =
      socket
      |> assign(:current_user_id, current_user_id)
      |> assign(:message, "")

    {:ok, socket}
  end

  def handle_event("send", %{"message" => %{"message" => message}}, socket) do
    socket = assign(socket, :message, message)

    Registry.dispatch(
      RoomRegistry,
      {socket.assigns.current_user_id, HelloWeb.RoomChannel},
      &for({pid, _} <- &1, do: send(pid, {:message, message}))
    )

    {:noreply, socket}
  end

  def handle_event("validate", %{"message" => %{"message" => _message}}, socket),
    do: {:noreply, socket}

  def handle_info({:message, message}, socket) do
    IO.inspect({__MODULE__, :message, message})
    socket = assign(socket, :message, message)
    {:noreply, socket}
  end
end
