defmodule Ueberauth.Strategy.Hatena do
  @moduledoc """
  Hatena Strategy for Überauth.
  """

  use Ueberauth.Strategy, uid_field: :url_name

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Strategy.Hatena

  @doc """
  Handles initial request for Hatena authentication.
  """
  def handle_request!(conn) do
    token = Hatena.OAuth.request_token!([], [redirect_uri: callback_url(conn)])

    conn
    |> put_session(:hatena_token, token)
    |> redirect!(Hatena.OAuth.authorize_url!(token))
  end

  @doc """
  Handles the callback from Hatena.
  """
  def handle_callback!(%Plug.Conn{params: %{"oauth_verifier" => oauth_verifier}} = conn) do
    token = get_session(conn, :hatena_token)
    case Hatena.OAuth.access_token(token, oauth_verifier) do
      {:ok, access_token} -> fetch_user(conn, access_token)
      {:error, error} -> set_errors!(conn, [error(error.code, error.reason)])
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:hatena_user, nil)
    |> put_session(:hatena_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.hatena_user[uid_field]
  end

  @doc """
  Includes the credentials from the hatena response.
  """
  def credentials(conn) do
    {token, secret} = conn.private.hatena_token

    %Credentials{token: token, secret: secret}
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.hatena_user

    %Info{
      image: user["profile_image_url"],
      name: user["url_name"],
      nickname: user["display_name"],
      urls: %{
        Hatena: "http://www.hatena.ne.jp/#{user["url_name"]}"
      }
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the hatena callback.
  """
  def extra(conn) do
    {token, _secret} = get_session(conn, :hatena_token)

    %Extra{
      raw_info: %{
        token: token,
        user: conn.private.hatena_user
      }
    }
  end

  defp fetch_user(conn, token) do
    case Hatena.OAuth.get("http://n.hatena.com/applications/my.json", [], token) do
      {:ok, {{_, 401, _}, _, _}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      {:ok, {{_, status_code, _}, _, body}} when status_code in 200..399 ->
        body = body |> List.to_string |> Poison.decode!

        conn
        |> put_private(:hatena_token, token)
        |> put_private(:hatena_user, body)
      {:ok, {_, _, body}} ->
        body = body |> List.to_string |> Poison.decode!

        error = List.first(body["errors"])
        set_errors!(conn, [error("token", error["message"])])
    end
  end

  defp option(conn, key) do
    Dict.get(options(conn), key, Dict.get(default_options, key))
  end
end
