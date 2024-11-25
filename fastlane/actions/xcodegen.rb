module Fastlane
  module Actions
    class XcodegenAction < Action
      def self.run(_params)
        binary_path = params[:xcodegen_path] || '/usr/local/bin/xcodegen'

        if !File.exist?(binary_path) && other_action.is_ci
          UI.message('Installing XcodeGen...')

          Actions.sh('curl -OL https://github.com/yonaskolb/XcodeGen/releases/download/2.25.0/xcodegen.zip')
          Actions.sh('unzip -q -o xcodegen.zip')
          Actions.sh('rm xcodegen.zip')
          Actions.sh('sh xcodegen/install.sh')
          Actions.sh('rm -rf xcodegen')
        end

        Actions.sh("#{binary_path.shellescape}")
      end

      def self.description
        'Installs and runs XcodeGen'
      end

      def self.authors
        ['evandcoleman']
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :xcodegen_path,
            env_name: 'XCODEGEN_PATH',
            description: 'Path to the XcodeGen binary',
            optional: true
          )
        ]
      end
    end
  end
end
