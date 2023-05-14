# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Campaigns", type: :system do
  context "when visiting the home page" do
    context "when there are no campaigns" do
      it "presents a message" do
        visit root_path
        expect(page).to have_content("No campaigns found")
      end
    end

    # Present a list of campaigns for which we have results.
    context "when there are campaigns" do
      it "presents a list of campaigns", :aggregate_failures do
        create(:campaign, name: "zzz_campaign_1", total_votes: 14)
        create(:campaign, name: "zzz_campaign_2", total_votes: 73)
        create(:campaign, name: "zzz_campaign_3", total_votes: 80)

        visit root_path
        expect(page).to have_content("Campaigns")
        expect(page).to have_content("zzz_campaign_1")
        expect(page).to have_content("14 votes")
        expect(page).to have_content("zzz_campaign_2")
        expect(page).to have_content("73 votes")
        expect(page).to have_content("zzz_campaign_3")
        expect(page).to have_content("80 votes")
      end
    end
  end
end
