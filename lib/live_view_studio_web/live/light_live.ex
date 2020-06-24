defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:brightness, 10)
      |> assign(:temperature, 3000)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Front Porch Light</h1>

    <div id="light">
      <div class="meter">
        <span style="width: <%= @brightness %>%; background-color: <%= temp_color(@temperature) %>">
          <%= @brightness %>%
        </span>
      </div>

      <label>Light temperature</label>

      <form phx-change="set_temperature">
        <input
          type="radio"
          name="temperature"
          id="3000"
          value="3000"
          <%= if @temperature == 3000, do: "checked" %>
        />

        <label for="3000">warm white</label>

        <input
          type="radio"
          name="temperature"
          id="4000"
          value="4000"
          <%= if @temperature == 4000, do: "checked" %>
        />

        <label for="4000">cool white</label>

        <input
          type="radio"
          name="temperature"
          id="5000"
          value="5000"
          <%= if @temperature == 5000, do: "checked" %>
        />

        <label for="5000">daylight</label>
      </form>

      <form phx-change="set_brightness">
        <input type="range" min="0" max="100" name="brightness" value="<%= @brightness %>" />
      </form>

      <button phx-click="off">
        <img src="images/light-off.svg">
      </button>

      <button phx-click="down">
        <img src="images/down.svg">
      </button>

      <button phx-click="up">
        <img src="images/up.svg">
      </button>

      <button phx-click="on">
        <img src="images/light-on.svg">
      </button>
    </div>
    """
  end

  def handle_event("set_brightness", %{"brightness" => brightness}, socket) do
    socket = assign(socket, :brightness, String.to_integer(brightness))

    {:noreply, socket}
  end

  def handle_event("set_temperature", %{"temperature" => temperature}, socket) do
    socket = assign(socket, :temperature, String.to_integer(temperature))

    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)

    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))

    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))

    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)

    {:noreply, socket}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"
end
