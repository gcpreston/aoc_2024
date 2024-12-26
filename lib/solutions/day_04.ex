defmodule Aoc2024.Day04 do
  defp parse_input(input) do
    input_lines = input |> String.trim() |> String.split("\n")

    for {line, row} <- Enum.with_index(input_lines) do
      for {char, col} <- Enum.with_index(String.graphemes(line)) do
        {{row, col}, char}
      end
    end
    |> List.flatten()
    |> Map.new()
  end

  def part1(input) do
    parse_input(input)
  end
end
