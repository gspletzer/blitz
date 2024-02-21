defmodule Blitz.Summoner do
  alias Blitz.RiotGames
  import Ecto.Changeset
  defstruct [:summoner, :region]

  @types %{
    summoner: :string,
    region: :string
  }

  @default_params %{
    "summoner" => "",
    "region" => ""
  }

  @match_count 5

  def changeset(params \\ @default_params) do
    cast({%__MODULE__{}, @types}, params, Map.keys(@types))
  end

  @doc """
  Fetches information about the summoner by summoner name for the given region.

  Returns an :ok tuple with second item being a map with Summoner's name, id, and region.
  """
  def fetch_summoner(name, region) do
    RiotGames.get_summoner_by_name(name, region)
  end

  @doc """
  Fetches most recent matches for a given summoner id within the designated region.
  The count argument will determine how many matches are returned.

  Returns an :ok tuple where second item is a list of match ids.
  """
  def fetch_matches(id, region, count) do
    RiotGames.get_matches_by_summoner_id(id, region, count)
  end

  @doc """
  Fetches particpants for the most recent matches played by given summoner in the
  designated region. For this project the number of recent matches collected is
  limited to 5.

  It will return an :ok tuple where second item is a list of sublists that contain
  a summoner's id and name. This originally was a list of tuples, but since the list
  is used as an argument in an Oban job and the args column doesn't support JSON encoding
  for tuples, it was changed to lists.
  """
  def fetch_participants(id, region) do
    with {:ok, matches} <- fetch_matches(id, region, @match_count),
         players <- RiotGames.get_participants_by_match_ids(matches, region),
         participants <-
           List.flatten(players)
           |> Enum.uniq()
           |> Enum.filter(fn player_id -> player_id != id end),
         summoners <- RiotGames.get_summoners_by_id(participants, region),
         true <-
           Enum.reject(summoners, fn summoner -> summoner != :error end) |> Enum.empty?() do
      {:ok, summoners}
    else
      _ -> :error
    end
  end
end
