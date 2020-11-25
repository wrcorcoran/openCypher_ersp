#
# Copyright (c) 2015-2020 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Attribution Notice under the terms of the Apache License 2.0
#
# This work was created by the collective efforts of the openCypher community.
# Without limiting the terms of Section 6, any Derivative Work that is not
# approved by the public consensus process of the openCypher Implementers Group
# should not be described as “Cypher” (and Cypher® is a registered trademark of
# Neo4j Inc.) or as "openCypher". Extensions by implementers or prototypes or
# proposals for change that have been documented or implemented should only be
# described as "implementation extensions to Cypher" or as "proposed changes to
# Cypher that are not yet approved by the openCypher community".
#

#encoding: utf-8

Feature: Return-OrderBy

  Scenario: Sort on aggregated function
    Given an empty graph
    And having executed:
      """
      CREATE ({division: 'A', age: 22}),
        ({division: 'B', age: 33}),
        ({division: 'B', age: 44}),
        ({division: 'C', age: 55})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.division, max(n.age)
        ORDER BY max(n.age)
      """
    Then the result should be, in order:
      | n.division | max(n.age) |
      | 'A'        | 22         |
      | 'B'        | 44         |
      | 'C'        | 55         |
    And no side effects

  Scenario: Support sort and distinct
    Given an empty graph
    And having executed:
      """
      CREATE ({name: 'A'}),
        ({name: 'B'}),
        ({name: 'C'})
      """
    When executing query:
      """
      MATCH (a)
      RETURN DISTINCT a
        ORDER BY a.name
      """
    Then the result should be, in order:
      | a             |
      | ({name: 'A'}) |
      | ({name: 'B'}) |
      | ({name: 'C'}) |
    And no side effects

  Scenario: Support ordering by a property after being distinct-ified
    Given an empty graph
    And having executed:
      """
      CREATE (:A)-[:T]->(:B)
      """
    When executing query:
      """
      MATCH (a)-->(b)
      RETURN DISTINCT b
        ORDER BY b.name
      """
    Then the result should be, in order:
      | b    |
      | (:B) |
    And no side effects

  Scenario: Count star should count everything in scope
    Given an empty graph
    And having executed:
      """
      CREATE (:L1), (:L2), (:L3)
      """
    When executing query:
      """
      MATCH (a)
      RETURN a, count(*)
      ORDER BY count(*)
      """
    Then the result should be, in any order:
      | a     | count(*) |
      | (:L1) | 1        |
      | (:L2) | 1        |
      | (:L3) | 1        |
    And no side effects

  @NegativeTest
  Scenario: Fail when sorting on variable removed by DISTINCT
    Given an empty graph
    And having executed:
      """
      CREATE ({name: 'A', age: 13}), ({name: 'B', age: 12}), ({name: 'C', age: 11})
      """
    When executing query:
      """
      MATCH (a)
      RETURN DISTINCT a.name
        ORDER BY a.age
      """
    Then a SyntaxError should be raised at compile time: UndefinedVariable

  Scenario: Ordering with aggregation
    Given an empty graph
    And having executed:
      """
      CREATE ({name: 'nisse'})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.name, count(*) AS foo
        ORDER BY n.name
      """
    Then the result should be, in any order:
      | n.name  | foo |
      | 'nisse' | 1   |
    And no side effects

  Scenario: Returning all variables with ordering
    Given an empty graph
    And having executed:
      """
      CREATE ({id: 1}), ({id: 10})
      """
    When executing query:
      """
      MATCH (n)
      RETURN *
        ORDER BY n.id
      """
    Then the result should be, in order:
      | n          |
      | ({id: 1})  |
      | ({id: 10}) |
    And no side effects

  Scenario: Using aliased DISTINCT expression in ORDER BY
    Given an empty graph
    And having executed:
      """
      CREATE ({id: 1}), ({id: 10})
      """
    When executing query:
      """
      MATCH (n)
      RETURN DISTINCT n.id AS id
        ORDER BY id DESC
      """
    Then the result should be, in order:
      | id |
      | 10 |
      | 1  |
    And no side effects

  Scenario: Returned columns do not change from using ORDER BY
    Given an empty graph
    And having executed:
      """
      CREATE ({id: 1}), ({id: 10})
      """
    When executing query:
      """
      MATCH (n)
      RETURN DISTINCT n
        ORDER BY n.id
      """
    Then the result should be, in order:
      | n          |
      | ({id: 1})  |
      | ({id: 10}) |
    And no side effects