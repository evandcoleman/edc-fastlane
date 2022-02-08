module Fastlane
  module Actions
    class ScanfileAction < Action
      def self.run(params)
        return params.load_configuration_file("Scanfile").options
      end

      def self.description
        "Gets the Scanfile params"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.available_options
        Scan::Options.available_options
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end