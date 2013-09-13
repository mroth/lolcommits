module Lolcommits
  PLUGINS = Lolcommits::Plugin.subclasses

  class Runner
    attr_accessor :capture_delay, :capture_device, :message, :sha,
      :snapshot_loc, :main_image, :repo, :config, :repo_internal_path,
      :font, :capture_animate

    include Methadone::CLILogging
    include ActiveSupport::Callbacks
    define_callbacks :run
    set_callback :run, :before, :execute_lolcommits_tranzlate

    # Executed Last
    set_callback :run, :after,  :cleanup!
    set_callback :run, :after,  :execute_lolcommits_hipchat
    set_callback :run, :after,  :execute_lolcommits_uploldz
    set_callback :run, :after,  :execute_lolcommits_lolsrv
    set_callback :run, :after,  :execute_lolcommits_lol_twitter
    set_callback :run, :after,  :execute_lolcommits_dot_com
    set_callback :run, :after,  :execute_lolcommits_loltext
    # Executed First

    def initialize(attributes={})
      attributes.each do |attr, val|
        self.send("#{attr}=", val)
      end

      if self.sha.nil? || self.message.nil?
        git_info = GitInfo.new
        self.sha = git_info.sha if self.sha.nil?
        self.message = git_info.message if self.message.nil?
        self.repo_internal_path = git_info.repo_internal_path
        self.repo = git_info.repo
      end
    end

    def run
      die_if_rebasing!

      run_callbacks :run do
        puts "*** Preserving this moment in history."
        self.snapshot_loc = self.config.raw_image(image_file_type)
        self.main_image   = self.config.main_image(self.sha, image_file_type)
        capturer = capturer_class.new(
          :capture_device    => self.capture_device,
          :capture_delay     => self.capture_delay,
          :snapshot_location => self.snapshot_loc,
          :font              => self.font,
          :video_location    => self.config.video_loc,
          :frames_location   => self.config.frames_loc,
          :animated_duration => self.capture_animate
        )
        capturer.capture
        resize_snapshot!
      end
    end

    def animate?
      capture_animate && (capture_animate.to_i > 0)
    end

    private
    def capturer_class
      "Lolcommits::Capture#{Configuration.platform}#{animate? ? 'Animated' : nil}".constantize
    end

    def image_file_type
      animate? ? 'gif' : 'jpg'
    end
  end

  protected
  def die_if_rebasing!
    debug "Runner: Making sure user isn't rebasing"
    if not self.repo_internal_path.nil?
      mergeclue = File.join self.repo_internal_path, "rebase-merge"
      if File.directory? mergeclue
        debug "Runner: Rebase detected, silently exiting!"
        exit 0
      end
    end
  end

  def resize_snapshot!
    debug "Runner: resizing snapshot"
    image = MiniMagick::Image.open(self.snapshot_loc)
    if (image[:width] > 640 || image[:height] > 480)
      #this is ghetto resize-to-fill
      image.combine_options do |c|
        c.resize '640x480^'
        c.gravity 'center'
        c.extent '640x480'
      end
      debug "Runner: writing resized image to #{self.snapshot_loc}"
      image.write self.snapshot_loc
    end
    debug "Runner: copying resized image to #{self.main_image}"
    FileUtils.cp(self.snapshot_loc, self.main_image)
  end

  def cleanup!
    debug "Runner: running cleanup"
    # clean up the captured image and any other raw assets
    FileUtils.rm(self.snapshot_loc)
    FileUtils.rm_f(self.config.video_loc)
    FileUtils.rm_rf(self.config.frames_loc)
  end

  # register a method called "execute_lolcommits_#{plugin_name}"
  # for each subclass of plugin.  these methods should be used as
  # callbacks to the run method.
  Lolcommits::PLUGINS.each do |plugin|
    define_method "execute_#{plugin.to_s.underscore.gsub('/', '_')}" do
      plugin.new(self).execute
    end
  end
end
