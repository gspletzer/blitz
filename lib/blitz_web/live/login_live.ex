defmodule BlitzWeb.LoginLive do
  use BlitzWeb, :live_view
  import BlitzWeb.CoreComponents

  def mount(_params, _session, socket) do
    new_entry = Blitz.new_entry()

    {:ok, assign(socket, :form, to_form(new_entry)) |> assign(:summoner, %{})}
  end

  def handle_event("login", %{"summoner" => params}, socket) do
    with {summoner, participants} <-
           Blitz.login(params["summoner"], params["region"]) do
      {:noreply,
       assign(socket, :summoner, summoner)
       |> assign(:participants, participants)}
    else
      _ ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Something went wrong fetching summoner information. Please try again."
         )}
    end
  end
end
