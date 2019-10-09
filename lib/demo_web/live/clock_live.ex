defmodule DemoWeb.ClockLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
    <%= inspect(@params) %>
    <%= for {{_k, v}, index} <- Enum.with_index(@params) do %>

    <%= if index == 0 do %>
        <div>
          <h2>It's <%= strftime!(v, "%r") %></h2>
          <%= live_render(@socket, DemoWeb.ImageLive, id: "image") %>
        <div>

    <% else %>

        <div>
          <h1 phx-click="boom">The count is: <span id="val" phx-hook="Count" phx-update="ignore"><%= v %></a></h1>
          <%= v %>
          <button phx-click="boom" class="alert-danger">BOOM</button>
          <button phx-click="dec">-</button>
          <button phx-click="inc" phx-debounce="1000">+</button>
        </div>

      <% end %>
    <% end %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, put_date(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_date(socket)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :params, fn [{_, _}, {_, value}] -> value = v + 1 end)}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, {:counter, :val}, fn {k, v} -> v = v - 1 end)}
  end

  defp put_date(socket) do
    assign(socket, params: [date: :calendar.local_time(), counter: 10])
  end

end
