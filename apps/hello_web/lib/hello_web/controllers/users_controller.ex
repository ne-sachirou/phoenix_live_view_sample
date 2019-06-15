defmodule HelloWeb.UsersController do
  use HelloWeb, :controller

  alias Hello.Accounts
  alias Hello.Accounts.Users

  def index(conn, _params) do
    {current_user_id, conn} = HelloWeb.Session.current_user_id(conn)
    conn = assign(conn, :current_user_id, current_user_id)
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_users(%Users{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"users" => users_params}) do
    case Accounts.create_users(users_params) do
      {:ok, users} ->
        conn
        |> put_flash(:info, "Users created successfully.")
        |> redirect(to: Routes.users_path(conn, :show, users))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    users = Accounts.get_users!(id)
    render(conn, "show.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    users = Accounts.get_users!(id)
    changeset = Accounts.change_users(users)
    render(conn, "edit.html", users: users, changeset: changeset)
  end

  def update(conn, %{"id" => id, "users" => users_params}) do
    users = Accounts.get_users!(id)

    case Accounts.update_users(users, users_params) do
      {:ok, users} ->
        conn
        |> put_flash(:info, "Users updated successfully.")
        |> redirect(to: Routes.users_path(conn, :show, users))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", users: users, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    users = Accounts.get_users!(id)
    {:ok, _users} = Accounts.delete_users(users)

    conn
    |> put_flash(:info, "Users deleted successfully.")
    |> redirect(to: Routes.users_path(conn, :index))
  end
end
