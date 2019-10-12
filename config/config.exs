# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :awesome,
  ecto_repos: [Awesome.Repo]

# Configures the endpoint
config :awesome, AwesomeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "u7M0yyUotpdcY6ryYZPS4WPhsqBNjo9TL35WWE2q0tPtEdFdyJB24NcuZKygWuw4",
  render_errors: [view: AwesomeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Awesome.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Custom environments
config :awesome,
  github_token: System.get_env("GITHUB_TOKEN"),
  link_for_parse: "h4cc/awesome-elixir"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
