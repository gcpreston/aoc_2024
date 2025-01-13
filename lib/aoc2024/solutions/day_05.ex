defmodule Aoc2024.Day05 do
  defp reorder_update(update, rules), do: reorder_update(update, [], rules)
  defp reorder_update([], prevs, _rules), do: Enum.reverse(prevs)

  defp reorder_update([cur | rest], prevs, rules) do
    in_order_prevs = Enum.reverse(prevs)
    first_invalid_index = Enum.find_index(in_order_prevs, fn prev -> prev in Map.get(rules, cur, []) end)

    if first_invalid_index do
      correct_up_to = if first_invalid_index == 0, do: [], else: Enum.slice(in_order_prevs, 0..(first_invalid_index - 1))
      # in_order_prevs[:first_invalid_index] + [cur] + in_order_prevs[first_invalid_index:] + rest
      updated_update = correct_up_to ++ [cur] ++ Enum.slice(in_order_prevs, first_invalid_index..-1//1) ++ rest
      reorder_update(updated_update, rules)
    else
      reorder_update(rest, [cur | prevs], rules)
    end
  end

  def part2(input) do
    {rules, updates} = parse_input(input)

    collective_rules = collect_rules(rules)

    Enum.reject(updates, &update_is_valid?(&1, collective_rules))
    |> Enum.map(&(reorder_update(&1, collective_rules)))
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end

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
