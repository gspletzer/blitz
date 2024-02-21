defmodule Blitz do
  alias Blitz.Summoner
  alias Blitz.SummonerWorker

  require Logger

  def new_entry() do
    Summoner.changeset()
  end

  @doc """
  Will fetch list of participants for 5 most recent matches played by
  the given summoner for the designated region.

  It will:
  - log the list of all the summoners the given summoner has played
  as an [info] message in the log/console
  - trigger the Oban job which will set up the subsequent match monitoring
  jobs for all summoners (original summoner included)
  - return a tuple with the original summoner map and the list of
  other summoners to be used on BlitzWeb (when applicable)
  """
  def login(name, region) do
    with {:ok, summoner} <- Summoner.fetch_summoner(name, region),
         {:ok, participants} <- Summoner.fetch_participants(summoner.id, region) do
      [[_id, name] | rest] = participants

      participants_string =
        Enum.reduce(rest, "#{name}", fn [_id, participant], acc -> acc <> ", " <> participant end)

      Logger.info("[#{participants_string}]")

      all_summoners = [[summoner.id, summoner.name] | participants]

      SummonerWorker.new(%{
        "region" => region,
        "summoners" => all_summoners
      })
      |> Oban.insert()

      {summoner, participants}
    else
      _ -> :error
    end
  end
end
