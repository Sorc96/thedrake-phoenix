defmodule DrakeWeb.GameLive.Components do
  alias Drake.{TroopStacks, Tile, GameState, PlayingSide}
  alias DrakeWeb.Router.Helpers, as: Routes

  import Phoenix.HTML.Link
  import DrakeWeb.ViewHelpers

  use Phoenix.Component

  def captured(assigns) do
    ~H"""
    <td class="captured"><%= "Captured: #{captured_count(@game, @side)}" %></td>
    """
  end

  def stack(assigns) do
    ~H"""
    <td
      class={if @selected, do: "selected"}
      style={"background-image:#{stack_image(@socket, @game, @side)}"}
      phx-click="click-stack"
      phx-value-side={Atom.to_string(@side)}>
    </td>
    """
  end

  def tile(assigns) do
    {x, y} = Tile.position(assigns.tile)

    ~H"""
    <td
      class={class_list(selected: @selected, move: @has_move)}
      style={"background-image:#{tile_image(@socket, @tile)}"}
      phx-click="click-tile"
      phx-value-x={x}
      phx-value-y={y}>
    </td>
    """
  end

  def status(assigns) do
    ~H"""
    <section class="row">
      <h2 class={"center #{color_class(@game)}"}><%= status_message(@game) %></h2>
    </section>
    <%= if GameState.victory?(@game) do %>
      <br>
      <section class="row">
        <%= link "Play again", to: Routes.live_path(@socket, DrakeWeb.GameLive.Show), class: "button center" %>
      </section>
    <% end %>
    """
  end

  defp captured_count(game, side) do
    TroopStacks.length(game.board.captured_troops, side)
  end

  defp stack_image(socket, game, side) do
    case TroopStacks.peek(game.troops, side) do
      nil ->
        ""

      troop ->
        path = Routes.static_path(socket, image_for_troop({troop, :front, side}))
        "url(#{path})"
    end
  end

  defp tile_image(socket, tile) do
    if Tile.has_troop?(tile) do
      troop = Tile.get_troop(tile)
      "url(#{Routes.static_path(socket, image_for_troop(troop))})"
    else
      ""
    end
  end

  defp image_for_troop({type, face, side}) do
    type_name = side_name(type)

    face_name = Atom.to_string(face)

    side_initial =
      side
      |> side_name()
      |> String.first()

    "/images/#{face_name}#{type_name}#{side_initial}.png"
  end

  defp color_class(state) do
    case side_for_message(state) do
      :blue -> "blue"
      :orange -> "orange"
    end
  end

  defp side_name(side) do
    side
    |> Atom.to_string()
    |> String.capitalize()
  end

  defp status_message(state) do
    player =
      state
      |> side_for_message()
      |> side_name()

    if state.status == :victory do
      "#{player} player won!"
    else
      "#{player} player's turn"
    end
  end

  defp side_for_message(%{status: :victory} = state), do: PlayingSide.opposite(state.side_on_turn)
  defp side_for_message(state), do: state.side_on_turn
end
