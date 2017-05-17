require 'methadone'

module Lolcommits
  # base class ala plugin.rb
  class VCSInfo
    include Methadone::CLILogging

    attr_accessor :sha, :message, :repo_internal_path, :repo, :url,
                  :author_name, :author_email, :branch

    def self.repo_root?(path = '.')
      GitInfo.repo_root?(path) || MercurialInfo.repo_root?(path)
    end

    def self.base_message(method)
      raise NotImplementedError, "#{self.class.name} is a base class; implement '#{method}' in a subclass", caller
    end

    def self.local_name(path = '.')
      if GitInfo.repo_root?(path)
        GitInfo.local_name(path)
      elsif MercurialInfo.repo_root?(path)
        MercurialInfo.local_name(path)
      else
        raise "'#{File.expand_path(path)}' is not the root of a supported VCS"
      end
    end

    def initialize
      base_message(__method__)
    end

    def branch
      base_message(__method__)
    end

    def message
      base_message(__method__)
    end

    def sha
      base_message(__method__)
    end

    def repo_internal_path
      base_message(__method__)
    end

    def url
      base_message(__method__)
    end

    def repo
      base_message(__method__)
    end

    def author_name
      base_message(__method__)
    end

    def author_email
      base_message(__method__)
    end
  end
end
