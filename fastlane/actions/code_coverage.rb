module Fastlane
  module Actions
    class CodeCoverageAction < Action
      def self.run(params)
        Actions.sh("curl -Os https://uploader.codecov.io/latest/macos/codecov")

        Actions.sh("chmod +x codecov")
        Actions.sh("./codecov -f #{params[:file].shellescape} --build #{ENV["BITRISE_BUILD_NUMBER"]} --pr #{ENV["BITRISE_PULL_REQUEST"]} --tag #{ENV["BITRISE_GIT_TAG"]} --branch #{ENV["BITRISE_GIT_BRANCH"]} --sha #{ENV["BITRISE_GIT_COMMIT"]} --token #{ENV["CODECOV_TOKEN"]}")
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