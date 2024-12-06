defmodule Aoc2024.Day01 do
  @day_number 1

  def part1 do
    input_lines =
      Aoc2024.input_for(@day_number)
      |> String.trim()
      |> String.split("\n")

    input_split = Enum.map(input_lines, &String.split/1)

    left = Enum.map(input_split, fn n -> String.to_integer(List.first(n)) end) |> Enum.sort()
    right = Enum.map(input_split, fn n -> String.to_integer(List.last(n)) end) |> Enum.sort()

    Enum.zip(left, right)
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end
end
