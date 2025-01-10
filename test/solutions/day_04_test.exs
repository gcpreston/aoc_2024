defmodule Aoc2024.Day04Test do
  use ExUnit.Case

  alias Aoc2024.Day04

  setup do
    input = """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """

    {data, row_count, col_count} = Day04.parse_input(input)
    acc = Day04.build_acc(row_count, col_count)

    %{data: data, acc: acc, row_count: row_count, col_count: col_count}
  end

  test "parse_input/1 parses correctly" do
    input = """
    XM
    AS
    """
    {data, row_count, col_count} = Day04.parse_input(input)

    assert row_count == 2
    assert col_count == 2
    assert %{{0, 0} => 1, {0, 1} => 2, {1, 0} => 3, {1, 1} => 4} == data
  end

  describe "next_space/3" do
    test "advances through row" do
      assert Day04.next_space({0, 0}, 2, 2) == {0, 1}
    end

    test "moves to the next row" do
      assert Day04.next_space({0, 1}, 2, 2) == {1, 0}
    end

    test "finishes processing" do
      assert Day04.next_space({1, 1}, 2, 2) == nil
    end
  end

  describe "matching_neighbors/3" do
    test "matches ahead for X", %{data: data, acc: acc} do
      space = {0, 5}
      assert Day04.matching_neighbors(data, acc[space], space) == [{{0, -1}, -1}, {{-1, 0}, -1}]
    end

    test "does not match ahead for M if not already started", %{data: data, acc: acc} do
      space = {0, 2}
      assert Day04.matching_neighbors(data, acc[space], space) == []
    end
  end

  describe "continue_matches/3" do
    test "sets matches to continue", %{acc: acc} do
      space = {0, 0}
      matches_to_continue = [{0, -1}, {-1, 0}]
      new_acc = Day04.continue_matches(acc, space, matches_to_continue)

      assert %{
        {0, 1} => %{{0, -1} => true, {-1, 0} => nil, {-1, -1} => nil, {-1, 1} => nil},
        {1, 0} => %{{0, -1} => nil, {-1, 0} => true, {-1, -1} => nil, {-1, 1} => nil}
      } = new_acc
    end
  end

  test "xmas_count/3 counts the XMASes", %{data: data, row_count: row_count, col_count: col_count} do
    assert Day04.xmas_count(data, row_count, col_count) == 18
  end
end
