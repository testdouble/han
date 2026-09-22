require "rails_helper"

RSpec.describe "GET /fibonacci", type: :request do
  it "returns the 10th fibonacci number" do
    get "/fibonacci", params: { n: 10 }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json["value"]).to eq(55)
  end
end
