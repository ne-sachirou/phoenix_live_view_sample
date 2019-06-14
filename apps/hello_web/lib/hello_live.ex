defmodule HelloWeb.HelloLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Count: <%= @count %>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :update)
    {:ok, assign(socket, :count, 0)}
  end

  def handle_info(:update, socket) do
    count = socket.assigns.count
    {:noreply, assign(socket, :count, count + 1)}
  end
end