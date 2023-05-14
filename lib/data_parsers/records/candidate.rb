# frozen_string_literal: true

require_relative "errors/invalid_vote_type_error"

module DataParsers
  module Records
    ValidityCounter = Struct.new(:pre, :during, :post, keyword_init: true) do
      def initialize(pre: 0, during: 0, post: 0)
        super
      end

      VALID_VOTE_TYPES.each do |validity|
        define_method("increment_#{validity}") do
          self[validity] += 1
        end
      end
    end

    class Candidate

      def initialize(name)
        @name = name
        @validity_counts = ValidityCounter.new(pre: 0, during: 0, post: 0)
      end

      def increment(validity)
        raise Errors::InvalidVoteTypeError, validity unless VALID_VOTE_TYPES.include?(validity)

        validity_counts.public_send("increment_#{validity}")
      end

      def total_votes
        validity_counts.values.sum
      end

      def to_h
        {
          name: name,
          total_votes: total_votes,
          invalid_votes: invalid_votes,
          validity_pre: pre,
          validity_during: during,
          validity_post: post
        }
      end

      private

      attr_reader :name, :validity_counts

      delegate :pre, :during, :post, to: :validity_counts

      def invalid_votes
        pre + post
      end

    end
  end
end
