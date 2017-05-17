require 'methadone'

module Lolcommits
  #
  # Methods to handle enabling and disabling of lolcommits
  #
  class Installation
    include Methadone::CLILogging

    def self.backend
      if GitInfo.repo_root?
        InstallationGit
      elsif MercurialInfo.repo_root?
        InstallationMercurial
      else
        fatal "You don't appear to be in the base directory of a supported vcs project."
        exit 1
      end
    end

    #
    # IF --ENABLE, DO ENABLE
    #
    def self.do_enable(options = {})
      capture_args = extract_capture_args(options)
      path         = backend.do_enable(capture_args)

      info 'installed lolcommit hook to:'
      info "  -> #{File.expand_path(path)}"
      info '(to remove later, you can use: lolcommits --disable)'
      # we dont symlink, but rather install a small stub that calls the one from path
      # that way, as gem version changes, script updates even if new file thus breaking symlink
    end

    #
    # IF --DISABLE, DO DISABLE
    #
    def self.do_disable
      backend.do_disable
    end

    # Extract any command line capture args from the parsed options hash, will
    # be appended to the capture command within the commit hook script
    #
    # @return [String]
    def self.extract_capture_args(options)
      options.map do |k, v|
        next unless %w(device animate delay stealth fork).include?(k)
        if k == 'device'
          "--device '#{v}'"
        else
          "--#{k}#{v == true ? '' : " #{v}"}"
        end
      end.compact.join(' ')
    end
  end
end
