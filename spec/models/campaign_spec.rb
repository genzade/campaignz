# frozen_string_literal: true

require "rails_helper"

RSpec.describe Campaign, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:campaign_episodes).dependent(:destroy) }
    it { is_expected.to have_many(:candidates).through(:campaign_episodes) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
