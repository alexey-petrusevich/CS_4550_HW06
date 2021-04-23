defmodule BullsWeb.PageController do
  use BullsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

# --------------------------------------------------------
# completed by using lecture notes of professor Nat Tuck
# --------------------------------------------------------