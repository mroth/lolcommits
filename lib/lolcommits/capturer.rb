require 'methadone'

module Lolcommits
  class Capturer
    include Methadone::CLILogging

    attr_accessor :capture_device, :capture_delay, :snapshot_location,
                  :video_location, :frames_location, :animated_duration

    def initialize(attributes = {})
      attributes.each do |attr, val|
        send("#{attr}=", val)
      end
      debug 'Capturer: initializing new instance ' + to_s
    end
  end
end

require 'lolcommits/capturer/capture_mac'
require 'lolcommits/capturer/capture_mac_animated'
require 'lolcommits/capturer/capture_linux'
require 'lolcommits/capturer/capture_linux_animated'
require 'lolcommits/capturer/capture_windows'
require 'lolcommits/capturer/capture_cygwin'
require 'lolcommits/capturer/capture_fake'
