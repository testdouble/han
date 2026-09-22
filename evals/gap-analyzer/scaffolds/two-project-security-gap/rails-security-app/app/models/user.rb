class User < ApplicationRecord
  self.table_name = "users"

  # Retrieves a user record by name.
  def self.find_by_name(name)
    query = "SELECT id, name, email, password, role FROM users WHERE name = '#{name}'"
    result = connection.select_one(query)
    return nil unless result

    user = new
    user.id = result["id"]
    user.name = result["name"]
    user.email = result["email"]
    user.password = result["password"]
    user.role = result["role"]
    user
  end

  # Retrieves a user record by numeric ID.
  def self.find_by_user_id(id)
    result = connection.select_one(
      sanitize_sql_array(["SELECT id, name, email, password, role FROM users WHERE id = ?", id])
    )
    return nil unless result

    user = new
    user.id = result["id"]
    user.name = result["name"]
    user.email = result["email"]
    user.password = result["password"]
    user.role = result["role"]
    user
  end
end
