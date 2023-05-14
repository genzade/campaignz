# frozen_string_literal: true

require "rails_helper"
require "data_parser"

RSpec.describe DataParser do
  it "returns parsed data structure" do
    data_file = file_fixture("vote_data/valid/sm/votes.txt")
    data_parser = DataParser.new(data_file)

    expect(data_parser.call).to contain_exactly(
      a_hash_including(
        campaign: "ssss_uk_01B",
        total_votes: 5,
        candidates: contain_exactly(
          a_hash_including(
            name: "Antony", total_votes: 1, validity_pre: 0, validity_post: 0, validity_during: 1
          ),
          a_hash_including(
            name: "Leon", total_votes: 2, validity_pre: 1, validity_post: 1, validity_during: 0
          ),
          a_hash_including(
            name: "Jane", total_votes: 2, validity_pre: 0, validity_post: 0, validity_during: 2
          )
        )
      ),
      a_hash_including(
        campaign: "ssss_uk_02B",
        total_votes: 5,
        candidates: contain_exactly(
          a_hash_including(
            name: "Jane", total_votes: 1, validity_pre: 0, validity_post: 0, validity_during: 1
          ),
          a_hash_including(
            name: "Leon", total_votes: 2, validity_pre: 1, validity_post: 1, validity_during: 0
          ),
          a_hash_including(
            name: "Matthew", total_votes: 2, validity_pre: 0, validity_post: 0, validity_during: 2
          )
        )
      ),
      a_hash_including(
        campaign: "ssss_uk_02A",
        total_votes: 4,
        candidates: contain_exactly(
          a_hash_including(
            name: "Verity", total_votes: 1, validity_pre: 0, validity_post: 0, validity_during: 1
          ),
          a_hash_including(
            name: "Leon", total_votes: 1, validity_pre: 0, validity_post: 0, validity_during: 1
          ),
          a_hash_including(
            name: "Gemma", total_votes: 2, validity_pre: 0, validity_post: 0, validity_during: 2
          )
        )
      )
    )
  end
end
