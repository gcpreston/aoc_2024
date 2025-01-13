defmodule Aoc2024.Day03 do
  defp do_mul(mul_str) do
    [n1, n2] =
      Regex.run(~r/mul\((\d+),(\d+)\)/, mul_str, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    n1 * n2
  end

  def part1(input) do
    captures = Regex.scan(~r/mul\(\d+,\d+\)/, input) |> List.flatten()

    captures
    |> Enum.map(&do_mul/1)
    |> Enum.sum()
  end

  defp tailor_muls(captures), do: tailor_muls(captures, true, [])

  defp tailor_muls([], _enabled, acc), do: acc
  defp tailor_muls(["do()" | rest], _enabled, acc), do: tailor_muls(rest, true, acc)
  defp tailor_muls(["don't()" | rest], _enabled, acc), do: tailor_muls(rest, false, acc)
  defp tailor_muls([_mul | rest], false, acc), do: tailor_muls(rest, false, acc)
  defp tailor_muls([mul | rest], true, acc), do: tailor_muls(rest, true, [do_mul(mul) | acc])

  def part2(input) do
    captures = Regex.scan(~r/mul\(\d+,\d+\)|do\(\)|don't\(\)/, input) |> List.flatten()

    captures
    |> tailor_muls()
    |> Enum.sum()
  end
end
