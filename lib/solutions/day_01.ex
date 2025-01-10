defmodule Aoc2024.Day01 do
  defp input_left_and_right(input) do
    input_lines =
      input
      |> String.trim()
      |> String.split("\n")

    input_split = Enum.map(input_lines, &String.split/1)

    left = Enum.map(input_split, fn n -> String.to_integer(List.first(n)) end) |> Enum.sort()
    right = Enum.map(input_split, fn n -> String.to_integer(List.last(n)) end) |> Enum.sort()

    {left, right}
  end

  def part1(input) do
    {left, right} = input_left_and_right(input)

    Enum.zip(left, right)
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end

  def part2(input) do
    {left, right} = input_left_and_right(input)

    occurrences =
      Enum.reduce(right, %{}, fn r, acc ->
        Map.update(acc, r, 1, fn r_old -> r_old + 1 end)
      end)

    left
    |> Enum.map(fn l -> Map.get(occurrences, l, 0) * l end)
    |> Enum.filter(fn l -> l != 0 end)
    |> Enum.sum()
  end
end
