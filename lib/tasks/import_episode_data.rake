# frozen_string_literal: true

require "data_parser"

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

          parsed_data.each do |campaign_data|
            campaign = Campaign.find_or_create_by!(name: campaign_data[:campaign])
            campaign.update!(total_votes: campaign_data[:total_votes])

            campaign_data[:candidates].each do |candidate_data|
              candidate = Candidate.find_or_create_by!(name: candidate_data[:name])

              CampaignEpisode.create!(
                candidate: candidate,
                campaign: campaign,
                score: candidate_data[:validity_during],
                invalid_votes: candidate_data[:invalid_votes]
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
      File.exist?(data_file_path)
    end

    def valid_data_file_type?
      VALID_DATA_FILE_TYPES.include?(File.extname(filename))
    end

    def data_file_path
      Rails.root.join("#{data_assets_dir}/#{filename}")
    end

    def data_assets_dir
      "#{Rails.env.test? ? 'spec/fixtures/files' : 'lib/assets'}/vote_data"
    end

    def parsed_data
      DataParser.call(data_file_path)
    end

  end
end

Tasks::ImportEpisodeData.new
