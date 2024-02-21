# Blitz

## Getting started

Greetings summoner!

To get started using the Blitz Stats app, you will need to first clone this repo. If you haven't done that before, you can check out GitHub's docs for cloning a repository [here](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository).

Once you have added it to your preferred local directory, navigate into the repo via `cd blitz`, then run `mix setup` in your terminal to install and setup dependencies. This will also handle creating your local copy of the database and running the initial migration.

Once setup is complete, you will want to add your own `.env` file to the root of this project. Refer to the `.env.sample` file for variable name and file pattern. At present this file only needs to contain your Riot Games development API key.

After you have added your own `.env` file, don't forget to source it, by running `source .env` in your terminal.

Now that that's done, you should be ready to use the app!

## Running Blitz in a browser

If you want to utilize the UI friendly version of the app, run `mix phx.server` in your terminal and then visit [`localhost:4000/login`](http://localhost:4000) from your browser.

You should see the landing page which will have an input boxes to submit the summoner name and designate the region you want to collect information for. If you don't have your own summoner name to test it out with, you can use `TSM Bjergsen` with the `North America` region selected.

A successful retrieval will display a `Welcome back <summoner_name>!` message as well as a list of recent opponents. Simultaneously, in the console, you will see an `[info]` message containg the list of recent opponents.

Assuming you don't kill your server, as you and your opponents complete new matches over the course of an hour following the initial fetch, you will notice a little green flash message appear on the screen which will denote which summoner completed the match, as well as the match ID. This message will also be logged in the console as an `[info]` message.

## Running Blitz in the terminal

If you prefer to use Blitz in the terminal, you can simply run `iex -S mix phx.server` or `iex -S mix` to get the app running.

Once the app is ready, then you can run `Blitz.login(<summoner_name>, <region>)` to kick off the same flow that the UI hits. The `summoner_name` should be entered as string with same spacing and capitalization that you would use in the UI input box. The region must be entered with as the correct abbreviation for the region you wish to query. If you are unfamiliar with regional server codes, you can find more information [here](https://leagueoflegends.fandom.com/wiki/Servers).

If you need some test arguments, you can use `"TSM Bergsen"` and `"na1"` for the summoner_name and region, respectively.

A successful fetch will yield the same `[info]` message in the console as the one returned when running in the browser, but you will also see it followed by the summoner map and list of participants with id and name in the console, since that is what gets passed back to the front end to render the display with summoner's name and list of opponents.

Just as in the browser version, for the hour following the initial fetch (assuming you don't shudown your server in the terminal) you will see `[info]` messages logged to the console each time you or an opponent complete a new match.

## Additional notes

- There will appear to be a slight lag when you run the initial fetch - just be patient as it is a complex series of chained API events so it takes a few seconds to run.

- If you click the refresh button in the browser after you complete a fetch you will be returned to the original form view.

- If you instantiate multiple `Blitz.login(name, region)` calls from the terminal, or refresh the browser and enter information again, you will eventually run into a rate limit error from Riot Games. More information about Riot Games API rate limits can be found [here](https://developer.riotgames.com/docs/portal#web-apis_rate-limiting). You will also encounter a rate limiting issue if you run two instances of the app with the same development API key.

- This project is using Oban jobs to facilitate the monitoring of matches completed after the initial fetch for opponents. You will be able to learn more about how that is running in the `Blitz.MatchWorker` module and via a
  database manager. For additional information about Oban, check out the [docs](https://hexdocs.pm/oban/Oban.html).
