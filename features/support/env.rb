require 'aruba/cucumber'
require 'open3'
require 'ffaker'
require 'fileutils'

require File.join(File.expand_path(File.dirname(__FILE__)), 'path_helpers')
include Lolcommits

World(PathHelpers)

Before do
  @aruba_timeout_seconds = 20

  # prevent launchy from opening gifs in tests
  set_env 'LAUNCHY_DRY_RUN', 'true'
  set_env 'LOLCOMMITS_CAPTURER', 'Lolcommits::CaptureFake'

  author_name  = 'Testy McTesterson'
  author_email = 'testy@tester.com'

  set_env 'GIT_AUTHOR_NAME',     author_name
  set_env 'GIT_COMMITTER_NAME',  author_name
  set_env 'GIT_AUTHOR_EMAIL',    author_email
  set_env 'GIT_COMMITTER_EMAIL', author_email
end

# for tasks that may take an incredibly long time (e.g. network related)
# we should strive to not have any of these in our scenarios, naturally.
Before('@slow_process') do
  @aruba_io_wait_seconds = 5
  @aruba_timeout_seconds = 60
end

# in order to fake an interactive rebase, we replace the editor with a script
# to simply squash a few random commits. in this case, using lines 3-5.
Before('@fake-interactive-rebase') do
  set_env 'GIT_EDITOR', "sed -i -e '3,5 s/pick/squash/g'"
end

# adjust the path so tests dont see a global imagemagick install
Before('@fake-no-imagemagick') do
  reject_paths_with_cmd('mogrify')
end

# adjust the path so tests dont see a global ffmpeg install
Before('@fake-no-ffmpeg') do
  reject_paths_with_cmd('ffmpeg')
end

# do test in temporary directory so our own git repo-ness doesn't affect it
Before('@in-tempdir') do
  @dirs = [Dir.mktmpdir]
end

After('@in-tempdir') do
  FileUtils.rm_rf(@dirs.first)
end
