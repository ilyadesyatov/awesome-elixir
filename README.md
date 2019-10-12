# Awesome Elixir

Application parsing every hour Markdown from [h4cc/awesome-elixir](https://github.com/h4cc/awesome-elixir). And saves data to the DB for further work with them.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Installing

In project root path, create .env file

[link](https://github.com/settings/tokens/new) for generating GitHub API personal access token.

```
export GITHUB_TOKEN="GitHub_API_token"
```

Run from root path of application run

```
source .env
```

### Create DB and run migrations

From root path, create db

```
mix ecto.create 
```

Run migrations

```
mix ecto.migrate
```

### Run application

Application launch

```
iex -S mix phx.server
```
Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running the tests
Run from root path of application run

```
source .env
```

then

```
mix test
```

## Author

[**Ilya Desyatov**](https://github.com/chirik)
