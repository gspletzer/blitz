defmodule Blitz.SummonerWorker do
  @moduledoc """
  Oban worker that spawns jobs to monitor all summoners for new matches
  completed over course of one hour following initial fetch of summoners list.
  """
  use Oban.Worker, queue: :game_monitor, max_attempts: 2

  require Logger

  alias Blitz.MatchWorker

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "region" => region,
          "summoners" => summoners
        }
      }) do
    stop_time = DateTime.utc_now() |> DateTime.add(60 * 60)

    Enum.each(summoners, fn [id, name] ->
      MatchWorker.new(%{
        "region" => region,
        "summoner_name" => name,
        "summoner_id" => id,
        "match_id" => "",
        "stop_time" => stop_time
      })
      |> Oban.insert()
    end)

    :ok
  end
end
