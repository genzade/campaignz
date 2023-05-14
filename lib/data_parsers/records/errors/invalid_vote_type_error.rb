# frozen_string_literal: true

module DataParsers
  module Records
    module Errors
      class InvalidVoteTypeError < StandardError

        def initialize(vote_type)
          super

          @vote_type = vote_type
        end

        def message
          "Invalid vote type: #{vote_type}, acceptable types are: #{DataParsers::VALID_VOTE_TYPES.join(', ')}"
        end

        private

        attr_reader :vote_type

      end
    end
  end
end
