module Fastlane
  module Actions
    class EditProjectSpecAction < Action
      def self.run(params)
        project = File.read('project.yml')

        unless params[:build_number].nil?
          project = project.gsub(/CURRENT_PROJECT_VERSION: (\d+)/, "CURRENT_PROJECT_VERSION: #{params[:build_number]}")
        end

        unless params[:version].nil?
          project = project.gsub(/MARKETING_VERSION: (\d{1,2}?\.\d{1,2}\.\d{1,2})/, "MARKETING_VERSION: #{params[:version]}")
        end

        File.open('project.yml', "w") {|file| file.puts project }
      end

      def self.description
        "Edits the xcodegen spec"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "PROJECT_SPEC_BUILD_NUMBER",
                                       description: "The build number",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version,
                                      env_name: "PROJECT_SPEC_VERSION",
                                      description: "The marketing version",
                                      optional: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end