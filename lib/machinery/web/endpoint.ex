defmodule Machinery.Endpoint do
  use Phoenix.Endpoint, otp_app: :machinery

  plug Plug.Static,
    at: "/", from: :machinery, gzip: false,
    only: ~w(css fonts images js)

  plug Plug.Session,
    store: :ets,
    key: "machinery_sid",
    table: :machinery_session

  plug Machinery.Router
end
