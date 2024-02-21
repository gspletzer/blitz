defmodule Blitz.MatchWorker do
  @moduledoc """
  Oban Worker that retrieves most recent `match_id` for the given summoner.

  If the `match_id` differs from the previous one, an `info` message is logged,
  stating which summoner completed the match as well as the new `match_id`.

  Whether or not the most recent `match_id` changes, it will spawn another job
  if `next_run_time` doesn't exceed the stop time.

  Stop time is one hour after the initial fetch of summoners completed. See
  Blitz.SummonerWorker for more information.
  """
  use Oban.Worker, queue: :game_monitor, max_attempts: 2

  require Logger

  alias Blitz.Summoner

  @count 1

  @check_time 60

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "region" => region,
          "summoner_id" => id,
          "summoner_name" => name,
          "match_id" => match_id,
          "stop_time" => stop_time
        }
      }) do
    {:ok, match_list} = Summoner.fetch_matches(id, region, @count)

    new_match_id = List.first(match_list)

    if new_match_id != match_id && match_id != "" do
      Logger.info("Summoner #{name} completed match #{new_match_id}")

      Phoenix.PubSub.broadcast(
        Blitz.PubSub,
        "new match",
        {:new_match_found, [name, new_match_id]}
      )
    end

    next_run_time = DateTime.utc_now() |> DateTime.add(60)

    if next_run_time >= stop_time do
      :ok
    else
      new(
        %{
          "region" => region,
          "summoner_id" => id,
          "summoner_name" => name,
          "match_id" => new_match_id,
          "stop_time" => stop_time
        },
        schedule_in: @check_time
      )
      |> Oban.insert()
    end
  end
end
