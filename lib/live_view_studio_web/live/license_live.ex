defmodule LiveViewStudioWeb.LicenseLive do
  use LiveViewStudioWeb, :live_view

  import Number.Currency

  alias LiveViewStudio.Licenses

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    expiration_time = Timex.shift(Timex.now(), hours: 1)

    socket =
      assign(
        socket,
        seats: 3,
        amount: Licenses.calculate(3),
        expiration_time: expiration_time,
        time_remaining: time_remaining(expiration_time)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Team License</h1>

    <div style="text-align: center; margin-bottom: 15px">
      Time remaining: <%= @time_remaining %>
    </div>

    <div id="license">
      <div class="card">
        <div class="content">
          <div class="seats">
            <img src="images/license.svg">
            <span>
              Your license is currently for
              <strong><%= @seats %></strong> seats.
            </span>
          </div>

          <form phx-change="update">
            <input type="range" min="1" max="10"
                  name="seats" value="<%= @seats %>" />
          </form>

          <div class="amount">
            <%= number_to_currency(@amount) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("update", %{"seats" => seats}, socket) do
    seats = String.to_integer(seats)

    socket =
      assign(socket,
        seats: seats,
        amount: Licenses.calculate(seats)
      )

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    socket = assign(socket, :time_remaining, time_remaining(socket.assigns.expiration_time))

    {:noreply, socket}
  end

  defp time_remaining(expiration_time) do
    Timex.Interval.new(from: Timex.now(), until: expiration_time)
    |> Timex.Interval.duration(:seconds)
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end
end
