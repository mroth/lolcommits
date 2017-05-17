require 'lolcommits/cli/command'
require 'lolcommits/cli/fatals'
require 'lolcommits/cli/launcher'
require 'lolcommits/cli/process_runner'
require 'lolcommits/cli/util'

module Lolcommits
  module CLI
    class CaptureCommand < Command
      # FIXME: make this option only show on supported platforms
      option ['-d', '--device'], 'NAME', "Optional device name, see `lolcommits devices`\n",
             environment_variable: 'LOLCOMMITS_DEVICE'

      # TODO: add a better test that this option only shows on appropriate platforms
      if Platform.can_animate?
        option ['-a', '--animate'], 'SECONDS', "Enable animated .GIF capture for duration\n",
               environment_variable: 'LOLCOMMITS_ANIMATE',
               default: 0 do |s|
                 Integer(s)
               end
      end

      option ['-w', '--delay'], 'SECONDS', "Delay capture to enable camera warmup\n",
             environment_variable: 'LOLCOMMITS_DELAY',
             default: 0 do |s|
               Integer(s)
             end

      option '--fork', :flag, "Fork capture process to background\n",
             environment_variable: 'LOLCOMMITS_FORK',
             default: false

      option '--stealth', :flag, "Capture image in stealth mode, e.g. no output\n",
             environment_variable: 'LOLCOMMITS_STEALTH',
             default: false

      # TODO: hide [dev mode] options from default help output unless LOLCOMMITS_DEVELOPER is set
      option ['-s', '--sha'], 'SHA', '[dev mode] override commit hash'
      option ['-m', '--msg'], 'MSG', '[dev mode] override commit message'

      def execute
        Fatals.die_on_fatal_platform_conditions!
        Fatals.die_if_no_valid_ffmpeg_installed! if animate != 0

        unless test?
          Fatals.die_if_not_vcs_repo!
          Util.change_dir_to_root_or_repo!
        end

        config = Configuration.new(PluginManager.init, test_mode: test?)
        capture_options = {
          capture_delay:    delay,
          capture_stealth:  stealth?,
          capture_device:   device,
          capture_animate:  Platform.can_animate? ? animate : 0,
          config:           config
        }
        process_runner = ProcessRunner.new(config)
        process_runner.fork_me?(fork?) do
          if test?
            info '*** Capturing in test mode.'
            capture_options[:message] = msg || 'this is a test message i didnt really commit something'
            capture_options[:sha] = sha || "test-#{rand(10**10)}"
          end

          runner = Lolcommits::Runner.new(capture_options)
          runner.run
          # automatically open the image in test mode
          Launcher.open_image(runner.main_image) if test?
        end
      end
    end
  end
end
