module Fastlane
  module Actions
    class UpdateBuildNumberAction < Action
      def self.run(params)
        time = Time.new
        build_number = other_action.get_ci_build_number || "1"
        date = time.strftime("%Y%m%d")
        build_number = "#{date}#{build_number}"

        UI.message "Updating build number fo #{build_number}..."

        other_action.edit_project_spec(build_number: build_number)

        return Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
      end

      def self.description
        "Creates a build number with the current date and updates the project spec"
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