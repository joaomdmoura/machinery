defmodule Machinery.Router do
  use Machinery.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Machinery do
    pipe_through :browser
    get "/", ResourceController, :index
  end

  scope "/api", Machinery do
    pipe_through :api
    post "/resources/:id", ResourceController, :update
    get "/resources/:state/:page", ResourceController, :index
  end
end
