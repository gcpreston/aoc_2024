defmodule Aoc2024.Day07 do
  defp parse_input(input) do
    input_lines = String.trim(input) |> String.split("\n")

    for line <- input_lines do
      [test_value_str, rest_str] = String.split(line, ": ")
      test_value = String.to_integer(test_value_str)
      numbers = String.split(rest_str, " ") |> Enum.map(&String.to_integer/1)
      {test_value, numbers}
    end
  end

  defp decimal_to_base_n_list(dec, n, operators_length) do
    Integer.to_string(dec, n)
    |> String.pad_leading(operators_length, "0")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp evaluate_eq_part1([first_n | numbers_rest], operators_id),
    do:
      evaluate_eq(
        numbers_rest,
        first_n,
        decimal_to_base_n_list(operators_id, 2, length(numbers_rest))
      )

  defp evaluate_eq_part2([first_n | numbers_rest], operators_id),
    do:
      evaluate_eq(
        numbers_rest,
        first_n,
        decimal_to_base_n_list(operators_id, 3, length(numbers_rest))
      )

  defp evaluate_eq([n], total, [op]), do: apply_operation(n, total, op)

  defp evaluate_eq([n | numbers_rest], total, [op_id | operators_rest]) do
    new_total = apply_operation(n, total, op_id)
    evaluate_eq(numbers_rest, new_total, operators_rest)
  end

  defp apply_operation(a, b, 0), do: a + b
  defp apply_operation(a, b, 1), do: a * b
  defp apply_operation(a, b, 2), do: String.to_integer(Integer.to_string(b) <> Integer.to_string(a))

  defp working?(test_value, numbers) do
    max_operator_id = 2 ** (length(numbers) - 1) - 1

    Enum.any?(0..max_operator_id, fn op_id ->
      evaluate_eq_part1(numbers, op_id) == test_value
    end)
  end

  defp working_part2?(test_value, numbers) do
    max_operator_id = 3 ** (length(numbers) - 1) - 1

    Enum.any?(0..max_operator_id, fn op_id ->
      evaluate_eq_part2(numbers, op_id) == test_value
    end)
  end

  # Wishlist
  # - evaluate_eq(numbers, operators_id)

  def part1(input) do
    data = parse_input(input)

    data
    |> Enum.filter(fn {test_value, numbers} -> working?(test_value, numbers) end)
    |> Enum.map(fn {test_value, _numbers} -> test_value end)
    |> Enum.sum()
  end

  def part2(input) do
    data = parse_input(input)

    data
    |> Enum.filter(fn {test_value, numbers} -> working_part2?(test_value, numbers) end)
    |> Enum.map(fn {test_value, _numbers} -> test_value end)
    |> Enum.sum()
  end
end
