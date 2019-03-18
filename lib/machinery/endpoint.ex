defmodule Machinery.Endpoint do
  @moduledoc """
  Endpoint module responsible for plugs and to handle authentication.
  """
  use Phoenix.Endpoint, otp_app: :machinery

  plug Plug.Static,
    at: "/", from: :machinery, gzip: false,
    only: ~w(css fonts images js)

  plug Plug.Session,
    store: :ets,
    key: "machinery_sid",
    table: :machinery_session

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Application.get_env(:phoenix, :json_library, Poison),
    length: 500_000_000

  auth_options = Application.get_env(:machinery, :authorization)
  if auth_options do
    plug BasicAuth, use_config: {:machinery, :authorization}
  end

  plug Machinery.Router
end
