# frozen_string_literal: true

require_relative "candidate"

module DataParsers
  module Records
    class Campaign

      attr_reader :campaign, :candidates

      def initialize(campaign)
        @campaign = campaign
        @candidates = {}
      end

      def add_vote(choice, validity)
        candidates[choice] ||= DataParsers::Records::Candidate.new(choice)
        candidates[choice].increment(validity)
      end

      def to_h
        {
          campaign: campaign,
          total_votes: total_votes,
          candidates: candidates.values.map(&:to_h)
        }
      end

      private

      def total_votes
        candidates.values.sum(&:total_votes)
      end

    end
  end
end
