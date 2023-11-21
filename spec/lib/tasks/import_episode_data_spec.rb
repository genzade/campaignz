# frozen_string_literal: true

require "rails_helper"

# loads all the rake tasks
Rails.application.load_tasks

RSpec.describe Tasks::ImportEpisodeData, type: :task do
  def rake_task
    Rake::Task["import_episode_data:run"]
  end

  after { rake_task.reenable }

  context "when the filename is not provided" do
    it "raises an error" do
      expect do
        rake_task.invoke
      end.to raise_error(ArgumentError, "filename not provided")
    end
  end

  context "when the filename is provided" do
    context "when the file is not a `txt` file" do
      it "raises an error" do
        expect do
          rake_task.invoke("filename.csv")
        end.to raise_error(ArgumentError, "You must provide a .txt file")
      end
    end

    context "when the file is a `txt` file" do
      context "when file does not exist" do
        it "raises an error" do
          expect do
            rake_task.invoke("filename.txt")
          end.to raise_error(StandardError, "filename.txt does not exist")
        end
      end

      context "when file exists" do
        it "creates the appropriate records" do
          campaign1 = an_object_having_attributes(name: "ssss_uk_01B", total_votes: 12)
          campaign2 = an_object_having_attributes(name: "ssss_uk_02B", total_votes: 11)
          campaign3 = an_object_having_attributes(name: "ssss_uk_02A", total_votes: 11)

          candidate_antony = an_object_having_attributes(name: "Antony")
          candidate_jane = an_object_having_attributes(name: "Jane")
          candidate_leon = an_object_having_attributes(name: "Leon")
          candidate_tupele = an_object_having_attributes(name: "Tupele")
          candidate_gemma = an_object_having_attributes(name: "Gemma")
          candidate_matthew = an_object_having_attributes(name: "Matthew")
          candidate_verity = an_object_having_attributes(name: "Verity")

          expect do
            rake_task.invoke("valid/m/votes.txt")
          end.to change(Campaign, :all)
            .from([])
            .to(
              a_collection_containing_exactly(campaign1, campaign2, campaign3)
            )
            .and(
              change(Candidate, :all)
              .from([])
              .to(
                a_collection_containing_exactly(
                  candidate_antony, candidate_jane, candidate_leon, candidate_tupele,
                  candidate_gemma, candidate_matthew, candidate_verity
                )
              )
            )
            .and(
              change(CampaignEpisode, :all)
              .from([])
              .to(
                a_collection_containing_exactly(
                  an_object_having_attributes(
                    campaign: campaign1,
                    candidate: candidate_antony,
                    score: 1,
                    invalid_votes: 0
                  ),
                  an_object_having_attributes(
                    campaign: campaign1,
                    candidate: candidate_leon,
                    score: 1,
                    invalid_votes: 2
                  ),
                  an_object_having_attributes(
                    campaign: campaign1,
                    candidate: candidate_tupele,
                    score: 2,
                    invalid_votes: 0
                  ),
                  an_object_having_attributes(
                    campaign: campaign1,
                    candidate: candidate_jane,
                    score: 3,
                    invalid_votes: 3
                  ),
                  an_object_having_attributes(
                    campaign: campaign2,
                    candidate: candidate_jane,
                    score: 2,
                    invalid_votes: 0
                  ),
                  an_object_having_attributes(
                    campaign: campaign2,
                    candidate: candidate_leon,
                    score: 2,
                    invalid_votes: 3
                  ),
                  an_object_having_attributes(
                    campaign: campaign2,
                    candidate: candidate_matthew,
                    score: 3,
                    invalid_votes: 1
                  ),
                  an_object_having_attributes(
                    campaign: campaign3,
                    candidate: candidate_verity,
                    score: 3,
                    invalid_votes: 1
                  ),
                  an_object_having_attributes(
                    campaign: campaign3,
                    candidate: candidate_leon,
                    score: 1,
                    invalid_votes: 0
                  ),
                  an_object_having_attributes(
                    campaign: campaign3,
                    candidate: candidate_antony,
                    score: 2,
                    invalid_votes: 1
                  ),
                  an_object_having_attributes(
                    campaign: campaign3,
                    candidate: candidate_gemma,
                    score: 2,
                    invalid_votes: 1
                  )
                )
              )
            )
          # .and(
          #   output(
          #     <<~OUTPUT
          #       system could not identify the chosen candidate for the following campaigns:
          #         - ssss_uk_zzactions
          #         - ssss_uk_xxactions
          #     OUTPUT
          #   ).to_stdout
          # )
        end

        context "when running the rake task more than once" do
          # before do
          #   rake_task.invoke("valid/m/votes.txt")
          # end

          it "only creates the data once, idempotent", :aggregate_failures do
            campaign1 = an_object_having_attributes(name: "ssss_uk_01B", total_votes: 12)
            campaign2 = an_object_having_attributes(name: "ssss_uk_02B", total_votes: 11)
            campaign3 = an_object_having_attributes(name: "ssss_uk_02A", total_votes: 11)

            candidate_antony = an_object_having_attributes(name: "Antony")
            candidate_jane = an_object_having_attributes(name: "Jane")
            candidate_leon = an_object_having_attributes(name: "Leon")
            candidate_tupele = an_object_having_attributes(name: "Tupele")
            candidate_gemma = an_object_having_attributes(name: "Gemma")
            candidate_matthew = an_object_having_attributes(name: "Matthew")
            candidate_verity = an_object_having_attributes(name: "Verity")

            expect do
              rake_task.invoke("valid/m/votes.txt")
              rake_task.reenable
              rake_task.invoke("valid/m/votes.txt")
            end.to not_change { Campaign.all.reload }
              .from(
                a_collection_containing_exactly(campaign1, campaign2, campaign3)
              )
              .and(
                not_change(Candidate, :all)
                .from(
                  a_collection_containing_exactly(
                    candidate_antony, candidate_jane, candidate_leon, candidate_tupele,
                    candidate_gemma, candidate_matthew, candidate_verity
                  )
                )
              )
              .and(
                not_change(CampaignEpisode, :all)
                .from(
                  a_collection_containing_exactly(
                    an_object_having_attributes(
                      campaign: campaign1,
                      candidate: candidate_antony,
                      score: 1,
                      invalid_votes: 0
                    ),
                    an_object_having_attributes(
                      campaign: campaign1,
                      candidate: candidate_leon,
                      score: 1,
                      invalid_votes: 2
                    ),
                    an_object_having_attributes(
                      campaign: campaign1,
                      candidate: candidate_tupele,
                      score: 2,
                      invalid_votes: 0
                    ),
                    an_object_having_attributes(
                      campaign: campaign1,
                      candidate: candidate_jane,
                      score: 3,
                      invalid_votes: 3
                    ),
                    an_object_having_attributes(
                      campaign: campaign2,
                      candidate: candidate_jane,
                      score: 2,
                      invalid_votes: 0
                    ),
                    an_object_having_attributes(
                      campaign: campaign2,
                      candidate: candidate_leon,
                      score: 2,
                      invalid_votes: 3
                    ),
                    an_object_having_attributes(
                      campaign: campaign2,
                      candidate: candidate_matthew,
                      score: 3,
                      invalid_votes: 1
                    ),
                    an_object_having_attributes(
                      campaign: campaign3,
                      candidate: candidate_verity,
                      score: 3,
                      invalid_votes: 1
                    ),
                    an_object_having_attributes(
                      campaign: campaign3,
                      candidate: candidate_leon,
                      score: 1,
                      invalid_votes: 0
                    ),
                    an_object_having_attributes(
                      campaign: campaign3,
                      candidate: candidate_antony,
                      score: 2,
                      invalid_votes: 1
                    ),
                    an_object_having_attributes(
                      campaign: campaign3,
                      candidate: candidate_gemma,
                      score: 2,
                      invalid_votes: 1
                    )
                  )
                )
              )

            # expect do
            #   rake_task.reenable

            #   rake_task.invoke("valid/m/votes.txt")
            # end.to not_change(Campaign, :count)
            #   .and(
            #     not_change(Candidate, :count)
            #   )
            #   .and(
            #     not_change(CampaignEpisode, :count)
            #   )
          end
        end
      end
    end
  end
end
