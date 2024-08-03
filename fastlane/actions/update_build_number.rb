module Fastlane
  module Actions
    class UpdateBuildNumberAction < Action
      def self.run(_params)
        time = Time.new
        if other_action.is_ci
          build_number = other_action.get_ci_build_number || '1'
        else
          full_build_number = other_action.get_current_build_number || '01'
          build_number = full_build_number[-2..-1].to_i + 1
        end
        puts build_number
        date = time.strftime('%Y%m%d')
        build_number = "#{date}#{format('%02d', build_number.to_i)}"

        UI.message "Updating build number fo #{build_number}..."

        other_action.edit_project_spec(build_number: build_number)

        Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
      end

      def self.description
        'Creates a build number with the current date and updates the project spec'
      end

      def self.authors
        ['evandcoleman']
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
