Feature: Disable command

  The disable command is used to disable lolcommits for a given VCS repository,
  based upon the current PWD of the user.

  Background:
    Given a mocked home directory

  Scenario: Help should format nicely on a 80x24 terminal
    When I successfully run `lolcommits disable --help`
    Then the output should not contain any lines longer than 80

  Scenario: Disable in a enabled git repo
    Given I am in a git repo with lolcommits enabled
    When I successfully run `lolcommits disable`
    Then the output should contain "uninstalled"
    And a file named ".git/hooks/post-commit" should exist
    And the exit status should be 0

  Scenario: Disable in a enabled mercurial repo
    Given I am in a mercurial repo with lolcommits enabled
    When I successfully run `lolcommits disable`
    Then the output should contain "uninstalled"
    And a file named ".hg/hgrc" should exist
    And the exit status should be 0
