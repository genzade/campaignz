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

          # TODO: come back here when you have the models
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

  end
end

Tasks::ImportEpisodeData.new
