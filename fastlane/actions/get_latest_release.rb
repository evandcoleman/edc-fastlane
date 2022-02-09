module Fastlane
  module Actions
    class GetLatestReleaseAction < Action
      def self.run(params)
        response = other_action.github_api(path: "/repos/#{params[:repo]}/releases/latest")
        return JSON.parse(response[:body])
      end

      def self.description
        "Gets the latest release for a given github repo"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repo,
                                       description: "owner/repo",
                                       optional: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end