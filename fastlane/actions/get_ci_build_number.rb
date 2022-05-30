module Fastlane
  module Actions
    class GetBuildNumberAction < Action
      def self.run(params)
        ENV["BITRISE_BUILD_NUMBER"] || ENV["GITHUB_RUN_NUMBER"]
      end

      def self.description
        "Gets build number from CI platform"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end