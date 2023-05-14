# frozen_string_literal: true

require "rails_helper"

RSpec.describe Candidate, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:campaign_episodes).dependent(:destroy) }
    it { is_expected.to have_many(:campaigns).through(:campaign_episodes) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
