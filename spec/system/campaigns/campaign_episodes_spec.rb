# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Campaigns, Campaign Episodes", type: :system do
  context "when visiting the campaign_episodes page" do
    context "when there are no campaign_episodes" do
      it "presents a message", :aggregate_failures do
        campaign = create(:campaign, name: "zzz_campaign_1", total_votes: 14)
        candidate1 = create(:candidate, name: "wade wilson")
        candidate2 = create(:candidate, name: "sergei valishnikov")

        create(
          :campaign_episode,
          campaign: campaign,
          candidate: candidate1,
          score: 6,
          invalid_votes: 3
        )
        create(
          :campaign_episode,
          campaign: campaign,
          candidate: candidate2,
          score: 4,
          invalid_votes: 1
        )

        visit campaign_campaign_episodes_path(campaign)

        expect(page).to have_content("zzz_campaign_1")
        expect(page).to have_content("wade wilson")
        expect(page).to have_content("6 votes")
        expect(page).to have_content("3 invalid votes")
        expect(page).to have_content("sergei valishnikov")
        expect(page).to have_content("4 votes")
        expect(page).to have_content("1 invalid vote")
      end
    end
  end
end
