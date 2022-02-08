module Fastlane
  module Actions
    class CodeCoverageAction < Action
      def self.run(params)
        Actions.sh("curl -Os https://uploader.codecov.io/latest/macos/codecov")

        Actions.sh("chmod +x codecov")
        Actions.sh("./codecov -f #{params[:file].shellescape}")
      end

      def self.description
        "Uploads a code coverage report to codecov.io"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       description: "The file to upload",
                                       optional: false),
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end