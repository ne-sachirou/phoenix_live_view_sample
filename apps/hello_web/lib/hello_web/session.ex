defmodule HelloWeb.Session do
  import Plug.Conn

  def current_user_id(conn) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      user_id = inspect(make_ref())
      conn = put_session(conn, :user_id, user_id)
      {user_id, conn}
    else
      {user_id, conn}
    end
  end
end
