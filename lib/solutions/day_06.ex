defmodule Aoc2024.Day06 do
  # IDEA
  # - Represent with same pos map technique
  # - Brute force solution: wishlist
  #   * walk(map, position, direction) : performs one move or turn and recurses until position leaves map boundaries
  #   * turn(direction) : return direction turned 90 degrees
  #   * move(position, direction) : return position moved forward one space

  # Direction
  # 0 : up
  # 1 : right
  # 2 : down
  # 3 : left

  defp parse_input(input) do
    input_lines = input |> String.trim() |> String.split("\n")

    map =
      for {line, row} <- Enum.with_index(input_lines) do
        for {char, col} <- Enum.with_index(String.graphemes(line)) do
          rep =
            if char == "^" do
              "."
            else
              char
            end

          {{row, col}, rep}
        end
      end
      |> List.flatten()
      |> Map.new()

    line_length = (Enum.at(input_lines, 0) |> String.length()) + 1
    starting_point_index = :binary.match(input, "^") |> elem(0)
    sp_row = div(starting_point_index, line_length)
    sp_col = rem(starting_point_index, line_length)

    {map, {sp_row, sp_col}, 0}
  end

  defp visited_positions(map, position, direction), do: visited_positions(map, position, direction, MapSet.new([position]))

  defp visited_positions(map, position, direction, visited) do
    case walk(map, position, direction) do
      {:continue, new_position, new_direction} -> visited_positions(map, new_position, new_direction, MapSet.put(visited, new_position))
      :exit -> visited
    end
  end

  defp walk(map, guard_position, guard_direction) do
    move_pos = move(guard_position, guard_direction)

    case Map.get(map, move_pos) do
      "." -> {:continue, move_pos, guard_direction}
      "#" -> {:continue, guard_position, turn(guard_direction)}
      nil -> :exit
    end
  end

  defp move(position, direction) do
    delta = direction_to_pos_delta(direction)
    pos_add(position, delta)
  end

  defp turn(direction), do: rem(direction + 1, 4)

  def part1(input) do
    {map, guard_position, guard_direction} = parse_input(input)
    visited_positions(map, guard_position, guard_direction) |> MapSet.size()
  end

  defp direction_to_pos_delta(0), do: {-1, 0}
  defp direction_to_pos_delta(1), do: {0, 1}
  defp direction_to_pos_delta(2), do: {1, 0}
  defp direction_to_pos_delta(3), do: {0, -1}

  defp pos_add({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}
end
