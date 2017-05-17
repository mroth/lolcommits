Feature: Commiting in a VCS triggers events

  Most of the time, lolcommits is not being invoked directly, but rather as a
  result of a commit in a VCS.

  Background:
    Given a mocked home directory

  Scenario: Commiting in an enabled git repo triggers successful capture
    Given I am in a git repo named "myrepo" with lolcommits enabled
    When I do a git commit
    Then the output should contain "*** Preserving this moment in history."
      And a directory named "~/.lolcommits/myrepo" should exist
      And a file named "~/.lolcommits/myrepo/tmp_snapshot.jpg" should not exist
      And there should be exactly 1 jpg in "~/.lolcommits/myrepo"

  Scenario: Commiting in enabled git repo subdirectory triggers successful capture
    Given I am in a git repo named "testcapture" with lolcommits enabled
      And a directory named "subdir"
      And an empty file named "subdir/FOOBAR"
    When I cd to "subdir/"
      And I do a git commit
    Then the output should contain "*** Preserving this moment in history."
      And a directory named "~/.lolcommits/testcapture" should exist
      And a directory named "~/.lolcommits/subdir" should not exist
      And there should be exactly 1 jpg in "~/.lolcommits/testcapture"

  Scenario: Commiting in stealth mode captures without alerting the committer
    Given I am in a git repo with lolcommits enabled
    And I have environment variable LOLCOMMITS_STEALTH set to 1
    When I do a git commit
    Then the output should not contain "*** Preserving this moment in history."
    And there should be exactly 1 jpg in its loldir

  Scenario: handle git commit messages with quotation marks
    Given I am in a git repo with lolcommits enabled
    When I successfully run `git commit --allow-empty -m 'no "air quotes" bae'`
    Then the exit status should be 0
    And there should be exactly 1 jpg in its loldir

  Scenario: Commiting in an enabled mercurial repo triggers successful capture
    Given I am in a mercurial repo named "myrepo" with lolcommits enabled
    When I do a mercurial commit
    Then the output should contain "*** Preserving this moment in history."
    And a directory named "~/.lolcommits/myrepo" should exist
    And a file named "~/.lolcommits/myrepo/tmp_snapshot.jpg" should not exist
    And there should be exactly 1 jpg in "~/.lolcommits/myrepo"

  Scenario: Commiting in enabled mercurial repo subdirectory triggers successful capture
    Given I am in a mercurial repo named "testcapture" with lolcommits enabled
    And a directory named "subdir"
    And an empty file named "subdir/FOOBAR"
    When I cd to "subdir/"
    And I do a mercurial commit
    Then the output should contain "*** Preserving this moment in history."
    And a directory named "~/.lolcommits/testcapture" should exist
    And a directory named "~/.lolcommits/subdir" should not exist
    And there should be exactly 1 jpg in "~/.lolcommits/testcapture"

  Scenario: handle mercurial commit messages with quotation marks
    Given I am in a mercurial repo with lolcommits enabled
    When I successfully run `touch meh`
    And I successfully run `hg add meh`
    And I successfully run `hg commit -m 'no "air quotes" bae'`
    Then the exit status should be 0
    And there should be exactly 1 jpg in its loldir
