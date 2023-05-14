# frozen_string_literal: true

module DataParsers
  VALID_VOTE_TYPES = %w[pre post during].freeze

  require_relative "data_parsers/records/campaign"
  require_relative "data_parsers/utils/file_encoder"
  require_relative "data_parsers/campaign_aggregator"
end
