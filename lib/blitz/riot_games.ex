defmodule Blitz.RiotGames do
  use Tesla

  require Logger

  plug(Tesla.Middleware.Headers, [
    {"X-Riot-Token", Application.get_env(:blitz, __MODULE__)[:api_key]}
  ])

  @match_regions %{
    "na1" => "americas",
    "br1" => "americas",
    "eun1" => "europe",
    "euw1" => "europe",
    "jp1" => "asia",
    "kr" => "asia",
    "la1" => "americas",
    "la2" => "americas",
    "oc1" => "sea",
    "ph2" => "sea",
    "ru" => "europe",
    "sg2" => "sea",
    "th2" => "sea",
    "tr1" => "europe",
    "tw2" => "sea",
    "vn2" => "sea"
  }

  @doc """
  Fetches a summoner by the name provided for the designated region.

  Returns either an :ok tuple where second item is a map with the summoner's
  name, id, and region, or :error.
  """
  def get_summoner_by_name(name, region) do
    encoded_name = URI.encode(name)

    {:ok, %{status: status, body: body}} =
      get("https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{encoded_name}")

    decoded_body = Jason.decode!(body)

    if status == 200 do
      summoner = %{
        id: decoded_body["puuid"],
        region: region,
        name: name
      }

      {:ok, summoner}
    else
      Logger.error(
        "Unable to retrieve summoner due to #{status} error. Details: #{decoded_body["status"]["message"]}"
      )

      :error
    end
  end

  @doc """
  Fetches most recent matches for the given summoner id within the designated region.

  Count indicates how many matches to return.

  Returns a list of match ids or :error.
  """
  def get_matches_by_summoner_id(id, region, count) do
    region_group = @match_regions[region]

    {:ok, %{body: body}} =
      get(
        "https://#{region_group}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{id}/ids",
        query: [count: count]
      )

    decoded_body = Jason.decode!(body)

    if is_list(decoded_body) do
      {:ok, decoded_body}
    else
      Logger.error("Unable to retrieve matches. Details: #{decoded_body["status"]["message"]}")

      :error
    end
  end

  @doc """
  Fetches participants for the given match ids within the designated region.

  The API returns additional match information, but this function will parse
  the response to only return the participants.

  Returns a list of results from fetching participants for each provided match id.
  Result will either be a list of participant ids, or :error.
  """
  def get_participants_by_match_ids(ids, region) do
    region_group = @match_regions[region]

    Enum.map(ids, fn match ->
      # added 1ms sleep to eliminate occassional rate limit error
      :timer.sleep(1)

      {:ok, %{status: status, body: body}} =
        get("https://#{region_group}.api.riotgames.com/lol/match/v5/matches/#{match}")

      decoded_body = Jason.decode!(body)

      if status == 200 do
        decoded_body["metadata"]["participants"]
      else
        Logger.error(
          "Unable to retrieve participants for match #{match} due to #{status} error. Details: #{decoded_body["status"]["message"]}"
        )

        :error
      end
    end)
  end

  @doc """
  Fetches summoners for each given summoner id within the designated region.

  Returns a list of results from fetching summoner info for each provided summoner id.
  Result will either be a list where first item is id and second is name, or :error.

  It returns id and name in a list, rather than a tuple because the information is used
  in Oban job arguments and JSON decoding wasn't working for tuple.
  """
  def get_summoners_by_id(ids, region) do
    Enum.map(ids, fn id ->
      :timer.sleep(1)

      {:ok, %{status: status, body: body}} =
        get("https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-puuid/#{id}")

      decoded_body = Jason.decode!(body)

      if status == 200 do
        [decoded_body["puuid"], decoded_body["name"]]
      else
        Logger.error(
          "Unable to retrieve participants for player #{id} due to #{status} error. Details: #{decoded_body["status"]["message"]}"
        )

        :error
      end
    end)
  end
end
