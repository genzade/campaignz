# frozen_string_literal: true

require "rails_helper"
require "data_parsers/records/campaign"

RSpec.describe DataParsers::Records::Campaign do
  it "returns a blank object ready to be propagated", :aggregate_failures do
    campaign = DataParsers::Records::Campaign.new("campaign_name")
    expect(campaign.to_h).to eq(
      campaign: "campaign_name",
      total_votes: 0,
      candidates: []
    )
  end

  describe "#add_vote" do
    context "with invalid vote type" do
      it "raises an error" do
        campaign = DataParsers::Records::Campaign.new("campaign_name")
        expect { campaign.add_vote("candidate_name", "invalid") }.to raise_error(
          DataParsers::Records::Errors::InvalidVoteTypeError,
          "Invalid vote type: invalid, acceptable types are: pre, post, during"
        )
      end
    end

    context "with valid vote type" do
      context "with vote type :pre" do
        it "increments the candidate's vote count" do
          candidate_name = "candidate_name"
          expected_candidate_hash = {
            name: candidate_name,
            total_votes: 1,
            invalid_votes: 1,
            validity_pre: 1,
            validity_post: 0,
            validity_during: 0
          }

          stub_candidate_record(expected_candidate_hash)

          campaign = DataParsers::Records::Campaign.new("campaign_name")

          expect do
            campaign.add_vote(candidate_name, "pre")
          end.to change { campaign.to_h }
            .from(
              a_hash_including(
                campaign: "campaign_name",
                total_votes: 0,
                candidates: []
              )
            )
            .to(
              a_hash_including(
                campaign: "campaign_name",
                total_votes: 1,
                candidates: [
                  expected_candidate_hash
                ]
              )
            )
        end
      end

      context "with vote type :post" do
        it "increments the candidate's vote count" do
          candidate_name = "candidate_name"
          expected_candidate_hash = {
            name: candidate_name,
            total_votes: 1,
            invalid_votes: 1,
            validity_pre: 0,
            validity_post: 1,
            validity_during: 0
          }

          stub_candidate_record(expected_candidate_hash)

          campaign = DataParsers::Records::Campaign.new("campaign_name")

          expect do
            campaign.add_vote(candidate_name, "post")
          end.to change { campaign.to_h }
            .from(
              a_hash_including(
                campaign: "campaign_name",
                total_votes: 0,
                candidates: []
              )
            )
            .to(
              a_hash_including(
                campaign: "campaign_name",
                total_votes: 1,
                candidates: [
                  expected_candidate_hash
                ]
              )
            )
        end
      end

      context "with vote type :during" do
        it "increments the candidate's vote count" do
          candidate_name = "candidate_name"
          expected_candidate_hash = {
            name: candidate_name,
            total_votes: 1,
            invalid_votes: 0,
            validity_pre: 0,
            validity_post: 0,
            validity_during: 1
          }

          stub_candidate_record(expected_candidate_hash)

          campaign = DataParsers::Records::Campaign.new("campaign_name")

          expect do
            campaign.add_vote(candidate_name, "during")
          end.to change { campaign.to_h }
            .from(
              a_hash_including(
                campaign: "campaign_name",
                total_votes: 0,
                candidates: []
              )
            )
            .to(
              a_hash_including(
                campaign: "campaign_name",
                total_votes: 1,
                candidates: [
                  expected_candidate_hash
                ]
              )
            )
        end
      end
    end
  end

  def stub_candidate_record(expected_candidate_hash)
    candidate_reacord = "DataParsers::Records::Candidate"

    class_double(
      candidate_reacord,
      new: instance_double(
        candidate_reacord,
        increment: 0,
        total_votes: 1,
        to_h: expected_candidate_hash
      )
    ).as_stubbed_const
  end
end
