module Fastlane
  module Actions
    class GeneratePresskitAction < Action
      def self.run(params)
        require 'tmpdir'
        require 'fileutils'
        # require 'mini_magick'

        Dir.mktmpdir do |tmp|
          dir = File.join(tmp, "presskit")
          FileUtils.mkdir(dir)

          # Copy screenshots
          unless params[:screenshots_path].nil?
            path = File.join(params[:screenshots_path], params[:locale], "*")
            dest = File.join(dir, "screenshots")
            framed_dest = File.join(dest, "app-store")
            FileUtils.mkdir_p(framed_dest)
            FileUtils.cp_r(Dir.glob(path), dest)
            if File.exist?(File.join(dest, "*_framed.*"))
              FileUtils.mv(Dir.glob(File.join(dest, "*_framed.*")), framed_dest)
            else
              FileUtils.mv(Dir.glob(dest), framed_dest)
            end
          end

          # Copy metadata
          app_id = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
          app = Spaceship::ConnectAPI::App.find(app_id)
          version = app.get_latest_app_store_version
          localization = version.get_app_store_version_localizations
            .find { |x| x.locale == params[:locale] }

          UI.user_error!("A localization for locale #{params[:locale]} does not exist for the latest app store version.") if localization.nil?

          File.write(File.join(dir, "description.txt"), localization.description)

          # Copy app icons
          unless params[:app_icon_paths].nil?
            dest = File.join(dir, "app-icons")
            FileUtils.mkdir_p(dest)

            script = %{
import Foundation
import UIKit

let path = CommandLine.arguments[1]
let image = UIImage(contentsOfFile: path)!
UIGraphicsBeginImageContextWithOptions(image.size, false, 2.0)
let rect = CGRect(origin: .zero, size: image.size)
UIBezierPath(roundedRect: rect, cornerRadius: image.size.width / 4).addClip()
image.draw(in: rect)
let newImage = UIGraphicsGetImageFromCurrentImageContext()!
UIGraphicsEndImageContext()
let data = newImage.pngData()!
try! data.write(to: URL(fileURLWithPath: path))
            }.strip
            script_path = File.join(dir, "round-corners.swift")
            command_path = File.join(dir, "round-corners")
            File.write(script_path, script)
            xcode_dir = `xcode-select -p`.strip
            sdk_root = File.join("/", xcode_dir, "Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk")
            ios_support = File.join("/", xcode_dir, "Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks")
            sdk_settings = JSON.parse(File.read(File.join(sdk_root, "SDKSettings.json")))
            sdk_version = sdk_settings["Version"]
            arch = `uname -m`.strip
            Actions.sh("xcrun -sdk macosx swiftc -F #{ios_support.shellescape} -framework UIKit -target #{arch}-apple-ios#{sdk_version}-macabi #{script_path.shellescape} -o #{command_path.shellescape}")

            params[:app_icon_paths].each do |k, v|
              path = File.join(dest, k.to_s)
              FileUtils.cp(v, path)

              Actions.sh("#{command_path.shellescape} #{path.shellescape}") if params[:round_app_icons]
            end

            FileUtils.rm(script_path)
            FileUtils.rm(command_path)
          end

          other_action.zip(
            path: dir,
            output_path: File.join(params[:output_path], "presskit.zip")
          )
        end
      end

      def self.description
        "Generates and compresses a press kit archive"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                       description: "Path to snapshot output folder",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :app_icon_paths,
                                       description: "Path to app icons to copy (key: target name, value: source path)",
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :round_app_icons,
                                       description: "Set to true to round corners of app icons",
                                       default_value: false,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :locale,
                                       description: "The locale to generate",
                                       default_value: "en-US",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       description: "The directory to output to",
                                       default_value: "fastlane",
                                       optional: false),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end