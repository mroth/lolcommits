Feature: Basic UI functionality

  Background:
    Given a mocked home directory

  Scenario: App just runs
    When I successfully run `lolcommits --help`
    Then the exit status should be 0

  Scenario: Help should format nicely on a 80x24 terminal
    When I successfully run `lolcommits --help`
    Then the output should not contain any lines longer than 80

  Scenario: Output version number
    When I successfully run `lolcommits version`
    Then the output should match /lolcommits \d\.\d+\.\d+\n/
