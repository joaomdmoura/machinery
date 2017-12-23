defmodule Machinery.Web.Router do
  use Machinery.Web.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Machinery.Web do
    pipe_through :browser

    get "/", PageController, :index
  end
end
