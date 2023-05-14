# frozen_string_literal: true

require "rails_helper"
require "data_parsers/records/errors/invalid_vote_type_error"

RSpec.describe DataParsers::Records::Errors::InvalidVoteTypeError do
  it "returns useful message" do
    stub_const("DataParsers::VALID_VOTE_TYPES", %w[some valid types])
    vote_type = "invalid"
    error = DataParsers::Records::Errors::InvalidVoteTypeError.new(vote_type)

    expect(error.message).to eq(<<~MSG.chomp)
      Invalid vote type: #{vote_type}, acceptable types are: some, valid, types
    MSG
  end
end
