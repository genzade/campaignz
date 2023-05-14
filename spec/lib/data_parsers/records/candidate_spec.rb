# frozen_string_literal: true

require "rails_helper"
require "data_parsers/records/candidate"

RSpec.describe DataParsers::Records::Candidate do
  it "returns a blank object ready to be propagated", :aggregate_failures do
    candidate = DataParsers::Records::Candidate.new("mercedes wilson")
    expect(candidate.total_votes).to eq(0)
    expect(candidate.to_h).to eq(
      name: "mercedes wilson",
      total_votes: 0,
      invalid_votes: 0,
      validity_pre: 0,
      validity_post: 0,
      validity_during: 0
    )
  end

  describe "#increment" do
    context "with invalid arguments" do
      it "raises an error" do
        candidate = DataParsers::Records::Candidate.new("mercedes wilson")
        expect { candidate.increment("invalid") }.to raise_error(
          DataParsers::Records::Errors::InvalidVoteTypeError,
          "Invalid vote type: invalid, acceptable types are: pre, post, during"
        )
      end
    end

    context "with valid arguments" do
      context "when incrementing :pre" do
        it "increments the specified votes", :aggregate_failures do
          candidate = DataParsers::Records::Candidate.new("mercedes wilson")
          candidate.increment("pre")

          expect(candidate.total_votes).to eq(1)
          expect(candidate.to_h).to eq(
            name: "mercedes wilson",
            total_votes: 1,
            invalid_votes: 1,
            validity_pre: 1,
            validity_post: 0,
            validity_during: 0
          )
        end
      end

      context "when incrementing :post" do
        it "increments the specified votes", :aggregate_failures do
          candidate = DataParsers::Records::Candidate.new("mercedes wilson")
          candidate.increment("post")

          expect(candidate.total_votes).to eq(1)
          expect(candidate.to_h).to eq(
            name: "mercedes wilson",
            total_votes: 1,
            invalid_votes: 1,
            validity_pre: 0,
            validity_post: 1,
            validity_during: 0
          )
        end
      end

      context "when incrementing :during" do
        it "increments the specified votes", :aggregate_failures do
          candidate = DataParsers::Records::Candidate.new("mercedes wilson")
          candidate.increment("during")

          expect(candidate.total_votes).to eq(1)
          expect(candidate.to_h).to eq(
            name: "mercedes wilson",
            total_votes: 1,
            invalid_votes: 0,
            validity_pre: 0,
            validity_post: 0,
            validity_during: 1
          )
        end
      end
    end
  end
end
