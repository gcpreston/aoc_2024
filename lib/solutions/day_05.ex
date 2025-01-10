defmodule Aoc2024.Day05 do
  defp parse_input(input) do
    text = input |> String.trim()

    [rules_text, updates_text] = String.split(text, "\n\n")

    rules =
      rules_text
      |> String.split("\n")
      |> Enum.map(fn rule_text ->
        String.split(rule_text, "|")
        |> Enum.map(&String.to_integer/1)
      end)

    updates =
      updates_text
      |> String.split("\n")
      |> Enum.map(fn rule_text ->
        String.split(rule_text, ",")
        |> Enum.map(&String.to_integer/1)
      end)

    {rules, updates}
  end

  defp collect_rules(rules), do: collect_rules(rules, %{})
  defp collect_rules([], acc), do: acc

  defp collect_rules([[first, second] | rest], acc) do
    new_acc =
      if Map.has_key?(acc, first) do
        dependents = acc[first]
        Map.put(acc, first, [second | dependents])
      else
        Map.put(acc, first, [second])
      end

    collect_rules(rest, new_acc)
  end

  defp update_is_valid?(update, rules), do: update_is_valid?(update, [], rules)
  defp update_is_valid?([], _prevs, _rules), do: true

  defp update_is_valid?([cur | rest], prevs, rules) do
    if Enum.any?(prevs, fn prev -> prev in Map.get(rules, cur, []) end) do
      false
    else
      update_is_valid?(rest, [cur | prevs], rules)
    end
  end

  defp get_middle(list), do: Enum.at(list, div(length(list), 2))

  def part1(input) do
    {rules, updates} = parse_input(input)

    # IDEA
    # 1. Iterate rules. For each number n, create list l of numbers which n must come before
    # 2. For each update u:
    # 3.   Base case - list length 1 -> valid
    # 4.   Recursive case - keep track of numbers already seen. If any numbers are in l -> invalid
    # 5. For each valid update, get the middle number, and sum

    collective_rules = collect_rules(rules)

    Enum.filter(updates, &update_is_valid?(&1, collective_rules))
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end
end
