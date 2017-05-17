Feature: Bug regression testing
  As a developer
  I want to ensure fixed bugs stay fixed
  So that I don't have to fix them again!

  Background:
    Given a mocked home directory

  #
  # issue #58, https://github.com/mroth/lolcommits/issues/58
  #
  Scenario: handle git repos with spaces in directory name
    Given I am in a git repo named "test lolol" with lolcommits enabled
    And I successfully run `git commit --allow-empty -m 'can haz commit'`
    Then the output should contain "*** Preserving this moment in history."
    And a directory named "../.lolcommits/test-lolol" should exist

  #
  # issue #68, https://github.com/mroth/lolcommits/issues/68
  #
  @fake-interactive-rebase @slow_process @unstable
  Scenario: Don't trigger capture during a git rebase
    Given I am in a git repo named "yuh8history" with lolcommits enabled
      And I do 6 git commits
    When I successfully run `git rebase -i HEAD~5`
    # Then there should be 4 commit entries in the git log
    Then there should be exactly 6 jpgs in "../.lolcommits/yuh8history"

  #
  # issue #81, https://github.com/mroth/lolcommits/issues/81
  #
  Scenario: don't want initialized constant warning from Faraday (MRI 1.8.7)
    When I successfully run `lolcommits`
    Then the output should not contain:
    """
    warning: already initialized constant DEFAULT_BOUNDARY
    """

  #
  # issue #87, https://github.com/mroth/lolcommits/issues/87
  #
  @fake-no-imagemagick
  Scenario: gracefully fail when imagemagick is not installed
    When I run `lolcommits enable`
    Then the output should contain:
      """
      ImageMagick does not appear to be properly installed
      """
    And the exit status should be 1

  #
  # issue #50, https://github.com/mroth/lolcommits/issues/50
  #
  Scenario: catch upstream bug with ruby-git and color=always
    Given I am in a git repo named "whatev" with lolcommits enabled
    And I successfully run `git config color.ui always`
    When I run `lolcommits enable`
    Then the output should contain:
      """
      Due to a bug in the ruby-git library, git config for color.ui cannot be set to 'always'.
      """
    And the output should contain "Try setting it to 'auto' instead!"
    And the exit status should be 1
