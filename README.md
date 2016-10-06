# Überauth Hatena

> Hatena strategy for Überauth.

Inspired by [Überauth for Twitter](https://github.com/ueberauth/ueberauth_twitter)

## Installation

1. Setup your application at [Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/auth/apis/oauth/consumer).

1. Add `ueberauth_hatena` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:oauth, github: "tim/erlang-oauth"},
       {:ueberauth_hatena, "~> 0.1.0"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_hatena]]
    end
    ```
1. Add Qiita to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        hatena: {Ueberauth.Strategy.Hatena, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Hatena.OAuth,
      consumer_key: System.get_env("HATENA_CONSUMER_KEY"),
      consumer_secret: System.get_env("HATENA_CONSUMER_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. You controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

## Calling

Depending on the configured url you can initial the request through:

    /auth/hatena

