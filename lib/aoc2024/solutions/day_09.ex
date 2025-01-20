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

      # ok wait how does this work LOL
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
    data = parse_input(input) |> dbg()
    shifted = shift(data)
    checksum(Enum.reverse(shifted))
  end

  ## Part 2

  defp parse_input_p2(input) do
    # Want:
    # - spaces front to back {index, size}
    # - files back to front {index, size, id}

    data = Enum.reverse(parse_input(input))

    {files, _idx} =
      Enum.reduce(data, {[], 0}, fn {file_id, count}, {acc, idx} ->
        new_acc =
          if is_nil(file_id) do
            acc
          else
            [{idx, count, file_id} | acc]
          end

        {new_acc, idx + count}
      end)

    files = Enum.reverse(files)

    {spaces, _idx} =
      Enum.reduce(data, {[], 0}, fn {file_id, count}, {acc, idx} ->
        new_acc =
          if is_nil(file_id) do
            [{idx, count} | acc]
          else
            acc
          end

        {new_acc, idx + count}
      end)

    spaces = Enum.reverse(spaces)

    {files, spaces}
  end

  defp shift_p2(files, spaces) do
    [first_file | rest_files] = files
    shift_p2(Enum.reverse(rest_files), spaces, [first_file])
  end

  defp shift_p2([], _spaces, acc), do: acc

  defp shift_p2([{_file_index, file_size, file_id} = last_file | rest_files] = files, spaces, acc) do
    IO.puts("----- SHIFTING")
    dbg(files)
    dbg(spaces)
    dbg(acc)

    maybe_fitting_space =
      Enum.with_index(spaces)
      |> Enum.find(fn {{_input_idx, space_size}, _space_idx} ->
        space_size >= file_size
      end)

    new_files = rest_files

    {new_spaces, new_acc} =
      case maybe_fitting_space do
        {{raw_index, space_size}, space_index} ->
          new_spaces =
            if space_size == file_size do
              List.delete_at(spaces, space_index)
            else
              List.replace_at(spaces, space_index, {raw_index + file_size, space_size - file_size})
            end

          {new_spaces, [{raw_index, file_size, file_id} | acc]}

        nil ->
          {spaces, [last_file | acc]}
      end

    shift_p2(new_files, new_spaces, new_acc)
  end

  defp checksum_p2(data) do
    Enum.reduce(data, 0, fn {file_index, file_size, file_id}, total ->
      file_checksum_part = file_id * Enum.sum(file_index..(file_index + file_size - 1))
      total + file_checksum_part
    end)
  end

  def part2(input) do
    # answer too high
    {files, spaces} = parse_input_p2(input)
    shift_p2(files, spaces)
    |> checksum_p2()
  end
end
