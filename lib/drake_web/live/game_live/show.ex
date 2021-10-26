defmodule DrakeWeb.GameLive.Show do
  use DrakeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Drake.new(), selected: nil)}
  end

  @impl true
  def handle_event("click-tile", %{"x" => x, "y" => y}, socket) do
    position = {String.to_integer(x), String.to_integer(y)}

    {:noreply, assign(socket, :selected, position)}
  end
end
