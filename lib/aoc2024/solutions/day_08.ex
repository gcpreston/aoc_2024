defmodule Aoc2024.Day08 do
  alias Aoc2024.Common

  # IDEA
  # 1. Create map Freq => List[Pos]
  # 2. For each Freq, for each combination of 2 Pos, find the two antinode coords
  # 3. If either of the antinode Pos are in-bounds, add them to the result set

  defp parse_input(input), do: parse_input(input, {0, 0}, {%{}, nil, nil})
  defp parse_input("", {r, _c}, {map, _num_rows, num_cols}), do: {map, r, num_cols}

  defp parse_input("\n" <> input_rest, {r, c}, {map, _num_rows, _num_cols}) do
    parse_input(input_rest, {r + 1, 0}, {map, nil, c})
  end

  defp parse_input("." <> input_rest, {r, c}, acc) do
    parse_input(input_rest, {r, c + 1}, acc)
  end

  defp parse_input(input, {r, c}, {map, rc, cc}) do
    node = String.at(input, 0)
    input_rest = binary_part(input, 1, byte_size(input) - 1)
    freq_coords = [{r, c} | Map.get(map, node, [])]
    new_map = Map.put(map, node, freq_coords)
    parse_input(input_rest, {r, c + 1}, {new_map, rc, cc})
  end

  defp possible_antinodes(pos1, pos2) do
    delta = Common.pos_sub(pos2, pos1)
    [Common.pos_add(pos2, delta), Common.pos_sub(pos1, delta)]
  end

  defp in_bounds?({r, c}, num_rows, num_cols) do
    r >= 0 && r < num_rows && c >= 0 && c < num_cols
  end

  defp antinode_line(pos1, pos2, num_rows, num_cols) do
    delta = Common.pos_sub(pos2, pos1)

    positive_ns =
      Stream.unfold(0, fn n -> {n, n + 1} end)
      |> Enum.take_while(fn n ->
        in_bounds?(Common.pos_add(pos1, Common.pos_mul(delta, n)), num_rows, num_cols)
      end)

    negative_ns =
      Stream.unfold(-1, fn n -> {n, n - 1} end)
      |> Enum.take_while(fn n ->
        in_bounds?(Common.pos_add(pos1, Common.pos_mul(delta, n)), num_rows, num_cols)
      end)

    positive_ns ++ negative_ns
    |> Enum.map(fn n -> Common.pos_add(pos1, Common.pos_mul(delta, n)) end)
  end

  defp all_freq_antinodes(coords, num_rows, num_cols) do
    combs = combinations(2, coords)

    Enum.reduce(combs, MapSet.new(), fn [pos1, pos2], acc ->
      new_antinodes =
        # possible_antinodes(pos1, pos2)
        # |> Enum.filter(fn antinode -> in_bounds?(antinode, num_rows, num_cols) end)
        antinode_line(pos1, pos2, num_rows, num_cols)
        |> MapSet.new()

      MapSet.union(acc, new_antinodes)
    end)
  end

  defp all_antinodes(map, num_rows, num_cols) do
    Enum.reduce(map, MapSet.new(), fn {_freq, coords}, acc ->
      MapSet.union(acc, all_freq_antinodes(coords, num_rows, num_cols))
    end)
  end

  # https://rosettacode.org/wiki/Combinations#Elixir
  def combinations(0, _), do: [[]]
  def combinations(_, []), do: []

  def combinations(m, [h | t]) do
    for(l <- combinations(m - 1, t), do: [h | l]) ++ combinations(m, t)
  end

  def part1(input) do
    {map, num_rows, num_cols} = parse_input(input)
    all_antinodes(map, num_rows, num_cols) |> dbg() |> MapSet.size()
  end
end
