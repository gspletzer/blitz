defmodule Blitz.LoginLive do
  use BlitzWeb, :live_view
  import BlitzWeb.CoreComponents

  def mount(_params, session, socket) do
    new_entry = Blitz.new_entry()

    {:ok, assign(socket, :form, to_form(new_entry))}
  end

  def handle_event("login", %{"entry" => params}, socket) do
    # fetch summoner stats, return list of 5 most recent matches, as well as id summoner
    {summoner_id, matches} = Blitz.login(id, region)

    {:noreply,
     assign(socket, :summoner_id, summoner_id)
     |> assign(:matches, matches)
     |> redirect(~p"/stats")}
  end
end
