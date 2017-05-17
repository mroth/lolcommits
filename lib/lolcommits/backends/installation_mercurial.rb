require 'methadone'

module Lolcommits
  #
  # Methods to handle enabling and disabling of lolcommits
  #
  class InstallationMercurial
    include Methadone::CLILogging

    HOOK_SECTION = 'hooks'.freeze
    HOOK_OPERATIONS = %w(commit record crecord).freeze

    #
    # IF --ENABLE, DO ENABLE
    #
    def self.do_enable(capture_args = '')
      if lolcommits_hook_exists?
        # clear away any existing lolcommits hook
        remove_existing_hook!
      end

      config = repository.config
      HOOK_OPERATIONS.each do |op|
        config.add_setting(HOOK_SECTION, "post-#{op}.lolcommits", hook_script(capture_args))
      end
      config.path
    end

    #
    # IF --DISABLE, DO DISABLE
    #
    def self.do_disable
      config = repository.config
      if lolcommits_hook_exists?
        remove_existing_hook!
        info "uninstalled lolcommits hook (from #{config.path})"
      elsif config.exists?
        info "couldn't find an lolcommits hook (at #{config.path})"
      else
        info "no post commit hook found (at #{config.path}), so there is nothing to uninstall"
      end
    end

    def self.hook_script(capture_args = '')
      ruby_path     = Lolcommits::Platform.command_which('ruby', true)
      imagick_path  = Lolcommits::Platform.command_which('identify', true)
      capture_cmd   = "if [ \"$LOLCOMMITS_CAPTURE_DISABLED\" != \"true\" ]; then lolcommits capture #{capture_args}; fi"
      exports       = "LANG=\"#{ENV['LANG']}\" && PATH=\"#{ruby_path}:#{imagick_path}:$PATH\""

      if Lolcommits::Platform.platform_windows?
        exports = "set path=#{ruby_path};#{imagick_path};%PATH%"
      end

      "#{exports} && #{capture_cmd}"
    end

    def self.repository
      Mercurial::Repository.open('.')
    end

    # does a mercurial hook exist with lolcommits commands?
    def self.lolcommits_hook_exists?
      config = repository.config
      config.exists? && config.setting_exists?(HOOK_SECTION, 'post-crecord.lolcommits')
    end

    # can we load the hgrc?
    def self.valid_hgrc?
      repository.config.exists?
    end

    def self.remove_existing_hook!
      config = repository.config
      HOOK_OPERATIONS.each do |op|
        setting = "post-#{op}.lolcommits"
        if config.setting_exists?(HOOK_SECTION, setting)
          config.delete_setting!(HOOK_SECTION, setting)
        end
      end
    end
  end
end
