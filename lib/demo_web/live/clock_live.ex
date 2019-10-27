defmodule DemoWeb.ClockLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
    <div>
      <h2>It's <%= strftime!(@date, "%r") %></h2>
    </div>

    <div>
      <h1>You have <span id="val" phx-hook="Count" phx-update="true"><%= @val %></a> Cookies</h1>
      <%= @val %>
      <button phx-click="inc" phx-debounce="1000">Cookies</button>
    </div>

    <div>
      <h3>You have <span id="bakers" phx-hook="Count" phx-update="true"><%= @bakers %></a> Bakers</h3>
      <p><%= @bakers/10 %> /s <button phx-click="dec_bakers">-</button>  <button phx-click="inc_bakers" phx-debounce="1000">+</button> </p>
     
    </div>
    """
  end

  def mount(session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
   
    {:ok, put_assigns(session, socket)}
  end

  def handle_info(:tick, socket) do
    bakers =
      socket
      |> Map.get(:assigns)
      |> Map.get(:bakers)
      
      {:noreply, update(socket, :val, &(&1 + bakers/10) |> truncate())}
  end

  def handle_event("nav", _path, socket) do
    {:noreply, socket}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1) |> truncate())}
  end

  def handle_event("inc_bakers", _, socket) do
    val =
    socket
      |> Map.get(:assigns)
      |> Map.get(:val)
    
    if(val >= 10) do
      result =
        socket
        |> update(:val, &(&1 - 10) |> truncate())
        |> update(:bakers, &(&1 + 1))
      {:noreply, result}
    else
      {:noreply, socket}
    end
  end

  def handle_event("dec_bakers", _, socket) do
    {:noreply, update(socket, :bakers, &(&1 - 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def truncate(value) do
    {result, _} = 
      :erlang.float_to_binary(value, [{:decimals, 3}, :compact])
      |> Float.parse()
    
    result
  end

  defp put_date(socket) do
    assign(socket, date: :calendar.local_time())
  end

  defp put_assigns(session, socket) do
    socket
    |> assign(date: :calendar.local_time())
    |> assign(:val, session[:val] || 0)
    |> assign(:bakers, session[:bakers] || 0)
  end

end
