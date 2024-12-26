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

  def is_safe_p2?([first | rest]) do
    is_safe_p2?(rest, {first, nil}, false)
  end

  defp is_safe_p2?([] = _report, _acc, _fault_flag), do: true

  defp is_safe_p2?([level | rest], {prev, operator}, fault_flag) do
    diff = prev - level

    operator =
      if is_nil(operator) do
        if diff > 0, do: :>, else: :<
      else
        operator
      end

    cond do
      abs(diff) <= 3 && abs(diff) > 0 && apply(:"Elixir.Kernel", operator, [diff, 0]) ->
        is_safe_p2?(rest, {level, operator}, fault_flag) || is_safe_p2?(rest, {prev, operator}, true)

      fault_flag ->
        false

      true ->
        is_safe_p2?(rest, {prev, operator}, true)
    end
  end

  defp is_safe_p2_new?(report) do
    reports_with_drops =
      for i <- 0..(length(report) - 1) do
        List.delete_at(report, i)
      end
    possible_reports = [report | reports_with_drops]

    Enum.any?(possible_reports, &is_safe?/1)
  end

  def part2(input) do
    # IDEA
    # - as we iterate through the list, if there is no fault yet, it's good if:
    #   * all conditions are met for this index
    #   * all conditions are met with fault flag set while removing current value
    #   * all conditions are met with fault flag set while removing previous value

    reports = parse_input(input)

    reports
    |> Enum.reduce(0, fn report, count ->
      if is_safe_p2_new?(report) do
        count + 1
      else
        count
      end
    end)
  end
end
