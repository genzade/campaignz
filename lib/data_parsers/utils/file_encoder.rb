# frozen_string_literal: true

module DataParsers
  module Utils
    class FileEncoder

      ENCODING = "ISO-8859-1"
      TARGET_ENCODING = "UTF-8"

      def self.call(data_file_path)
        new(data_file_path).call
      end

      def initialize(data_file_path)
        @data_file_path = data_file_path
      end

      def call
        # Force the encoding to UTF-8 to ensure that the data is properly parsed
        # see https://dev.to/bajena/solving-invalid-byte-sequence-in-utf-8-errors-in-ruby-1f27
        File.read(data_file_path, encoding: ENCODING).encode(TARGET_ENCODING)
      end

      private

      attr_reader :data_file_path

    end
  end
end
