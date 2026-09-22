class UsersController < ApplicationController
  # GET /users?name=<name>
  # Returns the matching user record as JSON.
  def show
    name = params[:name]
    if name.blank?
      render json: { error: "name parameter required" }, status: :bad_request
      return
    end

    user = User.find_by_name(name)
    if user.nil?
      render json: { error: "user not found" }, status: :not_found
      return
    end

    render json: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role
    }
  end
end
