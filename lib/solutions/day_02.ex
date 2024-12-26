defmodule Aoc2024.Day02 do
  defp parse_input(input) do
    lines =
      input
      |> String.trim()
      |> String.split("\n")

    for line <- lines do
      levels = line |> String.trim() |> String.split()

      for level <- levels do
        String.to_integer(level)
      end
    end
  end

  defp is_safe?(report) do
    [first | rest] = report

    diffs =
      rest
      |> Enum.reduce({[], first}, fn level, {diffs, prev} -> {[prev - level | diffs], level} end)
      |> elem(0)

    (Enum.all?(diffs, fn d -> d > 0 end) || Enum.all?(diffs, fn d -> d < 0 end)) &&
      Enum.all?(diffs, fn d -> abs(d) <= 3 end)
  end

  def part1(input) do
    reports = parse_input(input)

    reports
    |> Enum.reduce(0, fn report, count ->
      if is_safe?(report) do
        count + 1
      else
        count
      end
    end)
  end
end
