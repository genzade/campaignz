# frozen_string_literal: true

module Tasks
  class ImportEpisodeData

    NEW_LINE_CHAR = "\n"
    VALID_DATA_FILE_TYPES = %w[.txt].freeze

    include Rake::DSL

    def initialize
      namespace :import_episode_data do
        desc "This task will import log file data into the application"
        task :run, [:filename] => :environment do |_task, args|
          @filename = args.filename

          handle_task_run_errors!

          extract_data.each do |campaign_data|
            campaign = Campaign.find_or_create_by!(name: campaign_data[:campaign])
            campaign.update!(total_votes: campaign_data[:total_votes])

            campaign_data[:candidates].each do |candidate_data|
              candidate = Candidate.find_or_create_by!(name: candidate_data[:name])

              CampaignEpisode.create!(
                candidate: candidate,
                campaign: campaign,
                score: candidate_data[:validity_during],
                invalid_votes: candidate_data.values_at(:validity_pre, :validity_post).reduce(&:+)
              )
            end
          end
        end
      end
    end

    private

    attr_reader :filename

    def handle_task_run_errors!
      raise(ArgumentError, "filename not provided") if filename.blank?
      raise(ArgumentError, "You must provide a .txt file") unless valid_data_file_type?
      raise(StandardError, "#{filename} does not exist") unless data_file_exists?
    end

    def data_file_exists?
      File.exist?(data_file)
    end

    def valid_data_file_type?
      VALID_DATA_FILE_TYPES.include?(File.extname(filename))
    end

    def data_file
      Rails.root.join("#{data_assets_dir}/#{filename}")
    end

    def data_assets_dir
      "#{Rails.env.test? ? 'spec/fixtures' : 'lib/assets'}/vote_data"
    end

    # TODO: This method is too long and needs to be refactored
    def extract_data
      campaigns = {}

      data_file.open.read.encode!("UTF-8", "ISO-8859-1").each_line do |line|
        campaign_match = line.match(/Campaign:([^ ]+)/)
        choice_match = line.match(/Choice:([^ ]+)/)
        validity_match = line.match(/Validity:([^ ]+)/)

        next unless campaign_match && choice_match && validity_match

        campaign = campaign_match[1]
        choice = choice_match[1]
        validity = validity_match[1]

        campaigns[campaign] ||= {
          campaign: campaign,
          total_votes: 0,
          candidates: {}
        }

        campaign_data = campaigns[campaign]
        candidate_data = campaign_data[:candidates][choice] ||= {
          name: choice,
          total_votes: 0,
          validity_pre: 0,
          validity_post: 0,
          validity_during: 0
        }

        campaign_data[:total_votes] += 1
        candidate_data[:total_votes] += 1

        case validity
        when "pre"
          candidate_data[:validity_pre] += 1
        when "post"
          candidate_data[:validity_post] += 1
        when "during"
          candidate_data[:validity_during] += 1
        end
      end

      campaigns.values.map do |campaign_data|
        candidates = campaign_data[:candidates].values
        campaign_data[:candidates] = candidates
        campaign_data
      end
    end

  end
end

Tasks::ImportEpisodeData.new
