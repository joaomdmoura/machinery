defmodule MachineryTest.ErrorViewTest do
  use ExUnit.Case, async: true
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(Machinery.ErrorView, "404.html", []) ==
           "Page not found"
  end

  test "render 500.html" do
    assert render_to_string(Machinery.ErrorView, "500.html", []) ==
           "Server internal error"
  end

  test "render any other" do
    assert render_to_string(Machinery.ErrorView, "505.html", []) ==
           "Server internal error"
  end
end
