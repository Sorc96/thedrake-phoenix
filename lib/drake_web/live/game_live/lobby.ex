defmodule DrakeWeb.GameLive.Lobby do
  alias Drake.GameServer

  use DrakeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      identifier = GameServer.new()
      DrakeWeb.Endpoint.subscribe(identifier)
      {:ok, assign(socket, identifier: identifier)}
    else
      {:ok, assign(socket, identifier: nil)}
    end
  end

  @impl true
  def handle_info(%{event: "join"}, socket) do
    path =
      Routes.live_path(socket, DrakeWeb.GameLive.Show,
        identifier: socket.assigns.identifier,
        side: "blue"
      )

    {:noreply, push_redirect(socket, to: path)}
  end
end
