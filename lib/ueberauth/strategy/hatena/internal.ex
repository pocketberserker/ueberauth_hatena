# Copyright (c) 2015 Sean Callan

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule Ueberauth.Strategy.Hatena.OAuth.Internal do
  @moduledoc """
  A layer to handle OAuth signing, etc.
  """

  def get(url, extraparams, {consumer_key, consumer_secret, _}, token \\ "", token_secret \\ "") do
    creds = OAuther.credentials(
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      token: token,
      token_secret: token_secret
    )
    {header, params} =
      "get"
      |> OAuther.sign(url, extraparams, creds)
      |> OAuther.header

    HTTPoison.get(url, [header], params: params)
  end

  def params_decode(resp) do
    resp
    |> String.split("&", trim: true)
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(&List.to_tuple/1)
    |> Enum.into(%{})
    # |> Enum.reduce(%{}, fn({name, val}, acc) -> Map.put_new(acc, name, val) end)
  end

  def token(params) do
    params["oauth_token"]
  end

  def token_secret(params) do
    params["oauth_token_secret"]
  end
end
