require "rails_helper"

RSpec.describe "GET /pi", type: :request do
  it "returns pi to 100 decimal places" do
    get "/pi"

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json["result"]).to start_with("3.1415926535")
  end
end
