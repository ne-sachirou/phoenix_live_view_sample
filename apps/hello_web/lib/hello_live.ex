defmodule HelloWeb.HelloLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Count: <%= @count %>
    <button phx-click="reverse">リバ!</button>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :update)
    socket =
      socket
      |> assign(:count, 0)
      |> assign(:diff, 1)
    {:ok, socket}
  end

  def handle_event("reverse", _value, socket) do
    diff = socket.assigns.diff
    {:noreply, assign(socket, :diff, -diff)}
  end

  def handle_info(:update, socket) do
    count = socket.assigns.count
    diff = socket.assigns.diff
    {:noreply, assign(socket, :count, count + diff)}
  end
end