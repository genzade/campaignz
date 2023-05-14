# frozen_string_literal: true

require "data_parsers"

class DataParser

  NEW_LINE_CHAR = "\n"

  def self.call(data_file_path)
    new(data_file_path).call
  end

  def initialize(data_file_path)
    @encoded_file = DataParsers::Utils::FileEncoder.call(data_file_path)
    @campaign_aggregator = DataParsers::CampaignAggregator.new
  end

  def call
    process_data
    statistics
  end

  private

  attr_reader :encoded_file, :campaign_aggregator

  delegate :statistics, :add_vote, to: :campaign_aggregator

  def process_data
    encoded_file.split(NEW_LINE_CHAR).each do |line|
      campaign_match = line.match(/Campaign:([^ ]+)/)
      choice_match = line.match(/Choice:([^ ]+)/)
      validity_match = line.match(/Validity:([^ ]+)/)

      next unless campaign_match && choice_match && validity_match

      campaign = campaign_match[1]
      choice = choice_match[1]
      validity = validity_match[1]

      add_vote(campaign, choice, validity)
    end
  end

end
