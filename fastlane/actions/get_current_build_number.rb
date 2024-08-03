# a modified version of: https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/increment_version_number.rb

module Fastlane
  module Actions
    module SharedValues
      CURRENT_BUILD_NUMBER ||= :CURRENT_BUILD_NUMBER
    end

    class GetCurrentVersionAction < Action
      require 'shellwords'

      def self.run(_params)
        # this gets the current version from the project file

        uses_xcodegen = File.exist?('./project.yml')
        current_version = nil

        Dir.chdir(File.expand_path('.')) do
          begin
            raise 'No project.yml file found' unless uses_xcodegen

            project = YAML.load_file('./project.yml')
            settings = project['settings'] || project[:settings]
            base = settings['base'] || settings[:base]

            current_version = base['CURRENT_PROJECT_VERSION'] || base[:MARKETING_VERSION]
          rescue StandardError => e
            puts e
            current_version = ''
          end

          Actions.lane_context[SharedValues::CURRENT_VERSION_NUMBER] = current_version
        end

        Actions.lane_context[SharedValues::CURRENT_VERSION_NUMBER]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Gets the current version number from an XcodeGen spec or xcode project file'
      end

      def self.output
        [
          ['CURRENT_VERSION_NUMBER', 'The current version number']
        ]
      end

      def self.return_type
        :string
      end

      def self.return_value
        'The new version number'
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.available_options
        []
      end
    end
  end
end
