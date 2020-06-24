defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights

  def mount(_params, _session, socket) do
    socket = assign(socket, query: nil, flights: [], loading: false)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id="search">

      <form phx-submit="flight-search">
        <input type="text" name="query" value="<%= @query %>"
               placeholder="Flight number or airpoirt"
               autofocus autocomplete="off"
               <%= if @loading, do: "readonly" %> />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= flight.departure_time %>
                </div>
                <div class="arrives">
                  Arrives: <%= flight.arrival_time %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("flight-search", %{"query" => query}, socket) do
    send(self(), {:handle_search, query})

    socket = assign(socket, loading: true)

    {:noreply, socket}
  end

  def handle_info({:handle_search, query}, socket) do
    socket =
      case do_search(query) do
        [] ->
          socket
          |> put_flash(:info, "No flights matching \"#{query}\"")
          |> assign(flights: [], loading: false)

        flights ->
          socket
          |> clear_flash()
          |> assign(flights: flights, loading: false)
      end

    {:noreply, socket}
  end

  defp do_search(query) do
    query
    |> search_by_number()
    |> search_by_airport(query)
  end

  defp search_by_number(query) do
    Flights.search_by_number(query)
  end

  defp search_by_airport([], query) do
    query
    |> String.upcase()
    |> Flights.search_by_airport()
  end

  defp search_by_airport(results, _query), do: results
end
