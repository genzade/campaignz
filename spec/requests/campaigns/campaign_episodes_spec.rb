# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Campaigns::CampaignEpisodes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      campaign = create(:campaign)
      get "/campaigns/#{campaign.id}/campaign_episodes"
      expect(response).to have_http_status(:success)
    end
  end
end
