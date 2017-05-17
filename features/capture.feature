Feature: Capture command

  The capture command actually does some lolcommiting!

  Background:
    Given a mocked home directory

  Scenario: Help should format nicely on a 80x24 terminal
    When I successfully run `lolcommits capture --help`
    Then the output should not contain any lines longer than 80

  Scenario: Help should show the animate option on a Mac platform
    Given I am using a "darwin" platform
    When I successfully run `lolcommits capture --help`
    Then the output should contain "-a, --animate SECONDS"

  Scenario: Help should not show the animate option on a Windows plaftorm
    Given I am using a "win32" platform
    When I successfully run `lolcommits capture --help`
    Then the output should not contain "--animate"

  Scenario: Legacy capture syntax should work with deprecation warning
    Given I am in a git repo named "myrepo"
    And I do a git commit
    When I run `lolcommits --capture`
    Then the stderr should contain "DEPRECATION WARNING"
    Then the output should contain "*** Preserving this moment in history."
    And there should be exactly 1 jpg in "~/.lolcommits/myrepo"

  Scenario: Basic capture should function
    Given I am in a git repo named "myrepo"
    And I do a git commit
    When I run `lolcommits capture`
    Then the output should contain "*** Preserving this moment in history."
    And there should be exactly 1 jpg in "~/.lolcommits/myrepo"

  Scenario: Capture doesnt break in forked mode
    Given I am in a git repo named "forked"
    And I do a git commit
    When I run `lolcommits capture --fork`
    Then there should be exactly 1 pid in "~/.lolcommits/forked"
    When I wait for the child process to exit in "forked"
    Then a directory named "~/.lolcommits/forked" should exist
      And a file named "~/.lolcommits/forked/tmp_snapshot.jpg" should not exist
      And there should be exactly 1 jpg in "~/.lolcommits/forked"

  Scenario: Stealth mode does not alert the user
    Given I am in a git repo named "teststealth"
    And I do a git commit
    When I run `lolcommits capture --stealth`
    Then the output should not contain "*** Preserving this moment in history."
    And there should be exactly 1 jpg in "~/.lolcommits/teststealth"

  Scenario: test capture should work regardless of whether in a lolrepo
    Given I am in a directory named "nothingtoseehere"
    When I run `lolcommits capture --test`
    Then the output should contain "*** Capturing in test mode."
      And the output should not contain "path does not exist (ArgumentError)"
      And the exit status should be 0

  Scenario: test capture should store in its own test directory
    Given I am in a git repo named "randomgitrepo" with lolcommits enabled
    When I successfully run `lolcommits capture --test`
    Then a directory named "~/.lolcommits/test" should exist
    And a directory named "~/.lolcommits/randomgitrepo" should not exist

  @mac-only
  Scenario: should generate an animated gif on the Mac platform
    Given I am in a git repo named "animate"
      And I do a git commit
    When I run `lolcommits capture --animate=1`
    Then the output should contain "*** Preserving this moment in history."
      And a directory named "~/.lolcommits/animate" should exist
      And a file named "~/.lolcommits/animate/tmp_video.mov" should not exist
      And a directory named "~/.lolcommits/animate/tmp_frames" should not exist
      And there should be exactly 1 gif in "~/.lolcommits/animate"


  @fake-no-ffmpeg
  Scenario: gracefully fail when ffmpeg not installed and --animate is used
    Given I am using a "darwin" platform
    When I run `lolcommits capture --animate 3`
    Then the output should contain:
      """
      ffmpeg does not appear to be properly installed
      """
    And the exit status should be 1
