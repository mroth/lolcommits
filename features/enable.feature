Feature: Enable command

  The enable command is used to enable lolcommits for a given VCS repository,
  based upon the current PWD of the user.

  Background:
    Given a mocked home directory

  Scenario: Help should format nicely on a 80x24 terminal
    When I successfully run `lolcommits enable --help`
    Then the output should not contain any lines longer than 80

  Scenario: Enable in a naked git repo
    Given I am in a git repo
    When I successfully run `lolcommits enable`
    Then the output should contain "installed lolcommit hook to:"
      And the lolcommits git post-commit hook should be properly installed
      And the exit status should be 0

  Scenario: Enable in a git repo that already has a git post-commit hook
    Given I am in a git repo
    And a git post-commit hook with "#!/bin/sh\n\n/my/own/script"
    When I successfully run `lolcommits enable`
    Then the output should contain "installed lolcommit hook to:"
      And the lolcommits git post-commit hook should be properly installed
      And the git post-commit hook should contain "#!/bin/sh"
      And the git post-commit hook should contain "/my/own/script"
      And the exit status should be 0

  Scenario: Enable in a git repo that has git post-commit hook with a bad shebang
    Given I am in a git repo
    And a git post-commit hook with "#!/bin/ruby"
    And I run `lolcommits enable`
      Then the output should contain "doesn't start with a good shebang"
      And the git post-commit hook should not contain "lolcommits --capture"
      And the exit status should be 1

  Scenario: Enable in a git repo passing capture arguments
    Given I am in a git repo
    When I successfully run `lolcommits enable -w 5 --fork --stealth --device 'My Devce'`
    Then the git post-commit hook should contain "lolcommits --capture --delay 5 --fork --stealth --device 'My Devce'"
    And the exit status should be 0

  @in-tempdir
  Scenario: Trying to enable while not in a git repo fails
    Given I am in a directory named "svnrulez"
    When I run `lolcommits enable`
    Then the output should contain:
      """
      You don't appear to be in a directory of a supported vcs project.
      """
    And the exit status should be 1

  Scenario: Enable on windows platform setting PATH in git post-commit hook
    Given I am using a "win32" platform
      And I am in a git repo
    When I successfully run `lolcommits enable`
    Then the git post-commit hook should contain "set path"
    And the exit status should be 0

  Scenario: Enable in a naked mercurial repo
    Given I am in a mercurial repo
    When I successfully run `lolcommits enable`
    Then the output should contain "installed lolcommit hook to:"
    And the lolcommits mercurial post-commit hook should be properly installed
    And the exit status should be 0

  Scenario: Enable in a mercurial repo that already has a mercurial post-commit hook
    Given I am in a mercurial repo
    And a mercurial post-commit hook with "[hooks]\npost-commit.mine = /my/own/script"
    When I successfully run `lolcommits enable`
    Then the output should contain "installed lolcommit hook to:"
    And the lolcommits mercurial post-commit hook should be properly installed
    And the mercurial post-commit hook should contain "post-commit.mine = /my/own/script"
    And the exit status should be 0

  Scenario: Enable in a mercurial repo passing capture arguments
    Given I am in a mercurial repo
    When I successfully run `lolcommits enable -w 5 --fork`
    Then the mercurial post-commit hook should contain "lolcommits capture --delay 5 --fork"
    And the exit status should be 0
