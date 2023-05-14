# frozen_string_literal: true

module DataParsers
  class CampaignAggregator

    def initialize
      @campaigns = {}
    end

    def add_vote(campaign, choice, validity)
      campaigns[campaign] ||= DataParsers::Records::Campaign.new(campaign)
      campaigns[campaign].add_vote(choice, validity)
    end

    def statistics
      campaigns.values.map(&:to_h)
    end

    private

    attr_reader :campaigns

  end
end
