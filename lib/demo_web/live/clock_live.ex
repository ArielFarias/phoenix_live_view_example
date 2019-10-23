defmodule DemoWeb.ClockLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
      <div>
        <h2>It's <%= strftime!(@date, "%r") %></h2>
      </div>

      <div>
      <h1 phx-click="boom">The count is: <span id="val" phx-hook="Count" phx-update="true"><%= @val %></a></h1>
      <%= @val %>
      <button phx-click="boom" class="alert-danger">BOOM</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc" phx-debounce="1000">+</button>
    </div>
    """
  end

  def mount(session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
    IO.inspect session
    IO.inspect socket
    {:ok, put_assigns(session, socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_date(socket)}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  defp put_date(socket) do
    assign(socket, date: :calendar.local_time())
  end

  defp put_assigns(session, socket) do
    socket
    |> assign(date: :calendar.local_time())
    |> assign(:val, session[:val] || 0)
  end

end
