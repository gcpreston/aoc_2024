defmodule Aoc2024.Day09 do
  # Notes
  # even index => file size, odd index => free space size

  # IDEA
  # - work from front and back à la fois
  # - final format ex: [{0, 2}, {9, 2}, {8, 1}, {1, 3}, ...]
  # - intermediate format ex: [{0, 2}, {9, 2}, {nil, 1}, ..., {8, 4}]
  # - use deque package if needed: https://github.com/gamache/ets_deque

  # Wishlist
  # - checksum(data) : calculate the checksum of shifted data
  # - shift(data) : perform either one shift or do so recursively

  defp parse_input(input) do
    input = String.trim(input)

    # Note that this produces the data structure backwards-indexed
    Enum.reduce(Enum.with_index(String.graphemes(input)), [], fn {c, i}, acc ->
      n = String.to_integer(c)
      is_file? = rem(i, 2) == 0

      cond do
        n == 0 -> acc
        is_file? -> [{div(i, 2), n} | acc]
        true -> [{nil, n} | acc]
      end
    end)
  end

  defp checksum(data), do: checksum(data, 0, 0)
  defp checksum([], _index, total), do: total

  defp checksum([{file_id, file_size} | data_rest], index, total) do
    new_total = file_id * Enum.sum(index..(index + file_size - 1)) + total
    checksum(data_rest, index + file_size, new_total)
  end

  defp shift_once([{nil, _size} | rest], _space_index, _space_size), do: rest

  defp shift_once([{file_id, file_size} | rest] = data, space_index, space_size) do
    # cases
    # 1. can't move whole file, some remains
    # 2. can't fill whole space, some remains
    # 3. file moves perfectly into space

    cond do
      file_size > space_size ->
        # can't move whole file
        data
        |> List.replace_at(0, {file_id, file_size - space_size})
        |> List.replace_at(space_index, {file_id, space_size})

      file_size < space_size ->
        # can't fill whole space
        rest
        |> List.insert_at(space_index, {file_id, file_size})
        |> List.replace_at(space_index - 1, {nil, space_size - file_size})

      true ->
        # file fits perfectly
        rest
        |> List.replace_at(space_index - 1, {file_id, file_size})
    end
  end

  defp shift(data) do
    case last_open_space(data) do
      {space_index, space_size} ->
        new_data = shift_once(data, space_index, space_size)
        shift(new_data)

      nil ->
        data
    end
  end

  defp last_open_space(data), do: last_open_space(data, 0, nil)
  defp last_open_space([], _index, last_space), do: last_space

  defp last_open_space([{nil, space_size} | data_rest], space_index, _cur) do
    last_open_space(data_rest, space_index + 1, {space_index, space_size})
  end

  defp last_open_space([_ | data_rest], index, cur) do
    last_open_space(data_rest, index + 1, cur)
  end

  def part1(input) do
    data = parse_input(input)
    shifted = shift(data)
    checksum(Enum.reverse(shifted))
  end
end
