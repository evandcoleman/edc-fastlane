module Fastlane
  module Actions
    module SharedValues
      LOCAL_BINARY_PATH = :LOCAL_BINARY_PATH
    end

    class SetupLocalBinAction < Action
      def self.run(params)
        require 'tmpdir'

        return unless lane_context[SharedValues::LOCAL_BINARY_PATH].nil?

        temp_dir = Dir.mktmpdir("edc-fastlane-bin")
        UI.message("📁 Created temp folder at #{temp_dir} for binaries...")
        at_exit { FileUtils.remove_entry(temp_dir) }

        lane_context[SharedValues::LOCAL_BINARY_PATH] = temp_dir 
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Setup local binary path"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end