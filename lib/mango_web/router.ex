defmodule MangoWeb.Router do
  use MangoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :frontend  do
    plug MangoWeb.Plugs.LoadCustomer
    plug MangoWeb.Plugs.FetchCart
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MangoWeb do
    pipe_through [:browser, :frontend]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create

    get "/", PageController, :index
    get "/categories/:name", CategoryController, :show

    get "/cart", CartController, :show
    post "/cart", CartController, :add
    put "/cart", CartController, :update
  end

  scope "/", MangoWeb do
    pipe_through [:browser, :frontend, MangoWeb.Plugs.AuthenticateCustomer]

    get "/orders", CartController, :orders
    get "/logout", SessionController, :delete
    get "/checkout", CheckoutController, :edit
    put "/checkout/confirm", CheckoutController, :update
    resources "/tickets", TicketController, except: [:edit, :update, :delete]
  end

  scope "/admin", MangoWeb.Admin, as: :admin do
    pipe_through [:browser, :frontend]

    resources "/users", UserController
  end
end
