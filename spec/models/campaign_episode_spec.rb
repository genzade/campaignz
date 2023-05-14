# frozen_string_literal: true

require "rails_helper"

RSpec.describe CampaignEpisode, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:campaign) }
    it { is_expected.to belong_to(:candidate) }
  end
end
