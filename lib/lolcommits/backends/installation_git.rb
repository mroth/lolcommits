require 'methadone'

module Lolcommits
  #
  # Methods to handle enabling and disabling of lolcommits
  #
  class InstallationGit
    include Methadone::CLILogging

    HOOK_PATH = File.join '.git', 'hooks', 'post-commit'
    HOOK_DIR = File.join '.git', 'hooks'

    #
    # IF --ENABLE, DO ENABLE
    #
    def self.do_enable(capture_args = '')
      # its possible a hooks dir doesnt exist, so create it if so
      Dir.mkdir(HOOK_DIR) unless File.directory?(HOOK_DIR)

      # should add a shebang (or not) adding will rewrite hook file
      add_shebang = false
      if hook_file_exists?
        # clear away any existing lolcommits hook
        remove_existing_hook! if lolcommits_hook_exists?

        # if file is empty we should add a shebang (and rewrite hook)
        if File.read(HOOK_PATH).strip.empty?
          add_shebang = true
        elsif !good_shebang?
          # look for good shebang in existing hook, abort if none found
          warn "the existing hook (at #{HOOK_PATH}) doesn't start with a good shebang; like #!/bin/sh"
          exit 1
        end
      else
        add_shebang = true
      end

      File.open(HOOK_PATH, add_shebang ? 'w' : 'a') do |f|
        f.write("#!/bin/sh\n") if add_shebang
        f.write(hook_script(capture_args))
      end

      FileUtils.chmod 0o755, HOOK_PATH
      HOOK_PATH
    end

    #
    # IF --DISABLE, DO DISABLE
    #
    def self.do_disable
      if lolcommits_hook_exists?
        remove_existing_hook!
        info "uninstalled lolcommits hook (from #{HOOK_PATH})"
      elsif File.exist?(HOOK_PATH)
        info "couldn't find an lolcommits hook (at #{HOOK_PATH})"
        if File.read(HOOK_PATH) =~ /lolcommit/
          info "warning: an older-style lolcommit hook may still exist, edit #{HOOK_PATH} to remove it manually"
        end
      else
        info "no post commit hook found (at #{HOOK_PATH}), so there is nothing to uninstall"
      end
    end

    def self.hook_script(capture_args = '')
      ruby_path     = Lolcommits::Platform.command_which('ruby', true)
      imagick_path  = Lolcommits::Platform.command_which('identify', true)
      capture_cmd   = "if [ ! -d \"$GIT_DIR/rebase-merge\" ] && [ \"$LOLCOMMITS_CAPTURE_DISABLED\" != \"true\" ]; then lolcommits capture #{capture_args}; fi"
      exports       = "LANG=\"#{ENV['LANG']}\" && PATH=\"#{ruby_path}:#{imagick_path}:$PATH\""

      if Lolcommits::Platform.platform_windows?
        exports = "set path=#{ruby_path};#{imagick_path};%PATH%"
      end

      <<-EOS
### lolcommits hook (begin) ###
#{exports} && #{capture_cmd}
###  lolcommits hook (end)  ###
EOS
    end

    # does a git hook exist at all?
    def self.hook_file_exists?
      File.exist?(HOOK_PATH)
    end

    # does a git hook exist with lolcommits commands?
    def self.lolcommits_hook_exists?
      hook_file_exists? &&
        File.read(HOOK_PATH).to_s =~ /lolcommits.*\(begin\)(.*\n)*.*lolcommits.*\(end\)/
    end

    # does the git hook file have a good shebang?
    def self.good_shebang?
      File.read(HOOK_PATH).lines.first =~ %r{^\#\!.*\/bin\/.*sh}
    end

    def self.remove_existing_hook!
      hook = File.read(HOOK_PATH)
      out  = File.open(HOOK_PATH, 'w')
      skip = false

      hook.lines.each do |line|
        skip = true if !skip && (line =~ /lolcommits.*\(begin\)/)

        out << line unless skip

        skip = false if skip && (line =~ /lolcommits.*\(end\)/)
      end

      out.close
    end
  end
end
