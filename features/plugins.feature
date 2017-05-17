Feature: Plugins for lolcommits

  Background:
    Given a mocked home directory

  Scenario: Help should format nicely on a 80x24 terminal
    When I successfully run `lolcommits plugins --help`
    Then the output should not contain any lines longer than 80

  Scenario: Show plugins
    When I successfully run `lolcommits plugins list`
    Then the output should contain a list of plugins

  Scenario: Configuring loltext plugin in test mode affects test loldir not repo loldir
    Given I am in a git repo named "testmode-config-test"
    When I run `lolcommits plugins config --test loltext` interactively
      And I wait for output to contain "enabled:"
      Then I type "false"
    Then the output should contain "Successfully configured plugin: loltext"
    And a file named "~/.lolcommits/test/config.yml" should exist
    When I successfully run `lolcommits show-config --test`
    Then the output should match /loltext:\s+enabled: false/

  @in-tempdir
  Scenario: Configuring loltext plugin if not in a lolrepo
    Given I am in a directory named "gitsuxcvs4eva"
    When I run `lolcommits plugins config`
    Then the output should contain:
      """
      You don't appear to be in a directory of a supported vcs project.
      """
    And the exit status should be 1

  @slow_process @unstable
  Scenario: Lolcommits.com integration works
    Given I am in a git repo named "dot_com" with lolcommits enabled
    When I run `lolcommits plugins config` interactively
      And I wait for output to contain "Name of plugin to configure:"
      Then I type "dot_com"
      And I wait for output to contain "enabled:"
      Then I type "true"
      And I wait for output to contain "api_key:"
      Then I type "b2a70ac0b64e012fa61522000a8c42dc"
      And I wait for output to contain "api_secret:"
      Then I type "b2a70ac0b64e012fa61522000a8c42dc"
      And I wait for output to contain "repo_id:"
      Then I type "b2a70ac0b64e012fa61522000a8c42dc"
    Then the output should contain "Successfully configured plugin: dot_com"
