class SessionsController < ApplicationController
  # POST /login
  # Authenticates a user with username and password, then creates a session.
  def create
    username = params[:username]
    password = params[:password]

    if username.blank? || password.blank?
      render json: { error: "invalid request body" }, status: :bad_request
      return
    end

    user = User.find_by_name(username)
    if user.nil?
      render json: { error: "invalid credentials" }, status: :unauthorized
      return
    end

    if user.password != password
      render json: { error: "invalid credentials" }, status: :unauthorized
      return
    end

    session[:user_id] = user.id
    session[:role] = user.role

    render json: { status: "logged_in", user_id: user.id }
  end
end
