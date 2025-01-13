defmodule Aoc2024.Day04 do
  alias Aoc2024.Common

  ## Part 2

  # IDEA
  # 1. Find all As within {1, 1} : {n-1, n-1}
  # 2. Get corner values
  # 3. Ensure 2 Ms 2 Ss, where like letters are adjacent

  defp get_a_positions(data, row_count, col_count) do
    for r <- 1..(row_count - 2) do
      for c <- 1..(col_count - 2) do
        if data[{r, c}] == 3 do
          {r, c}
        end
      end
      |> Enum.filter(&(!is_nil(&1)))
    end
    |> List.flatten()
  end

  def is_x_mas?(data, pos) do
    corners_delta = [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}]
    corners_pos = Enum.map(corners_delta, fn cd -> Common.pos_add(pos, cd) end)

    # condition
    # - 2 Ms 2 Ss
    # - either {-1, -1}, {-1, 1} are the same OR {-1, -1}, {1, -1} are the same

    corners_vals = Enum.map(corners_pos, fn cp -> data[cp] end)

    Enum.frequencies(corners_vals) == %{2 => 2, 4 => 2} &&
      (data[Common.pos_add(pos, {-1, -1})] == data[Common.pos_add(pos, {-1, 1})] ||
         data[Common.pos_add(pos, {-1, -1})] == data[Common.pos_add(pos, {1, -1})])
  end

  def part2(input) do
    {data, row_count, col_count} = parse_input(input)

    get_a_positions(data, row_count, col_count)
    |> Enum.filter(fn pos -> is_x_mas?(data, pos) end)
    |> Enum.count()
  end

  ## Part 1

  def parse_input(input) do
    input_lines = input |> String.trim() |> String.split("\n")

    data =
      for {line, row} <- Enum.with_index(input_lines) do
        for {char, col} <- Enum.with_index(String.graphemes(line)) do
          rep =
            case char do
              "X" -> 1
              "M" -> 2
              "A" -> 3
              "S" -> 4
            end

          {{row, col}, rep}
        end
      end
      |> List.flatten()
      |> Map.new()

    row_count = length(input_lines)
    col_count = String.length(hd(input_lines))

    {data, row_count, col_count}
  end

  defp new_neighbor_match do
    %{{-1, -1} => nil, {-1, 0} => nil, {-1, 1} => nil, {0, -1} => nil}
  end

  def build_acc(row_count, col_count) do
    for r <- 0..(row_count - 1) do
      for c <- 0..(col_count - 1) do
        {{r, c}, new_neighbor_match()}
      end
    end
    |> List.flatten()
    |> Map.new()
  end

  def next_space({r, c}, _row_count, col_count) when c < col_count - 1, do: {r, c + 1}
  def next_space({r, _c}, row_count, _col_count) when r < row_count - 1, do: {r + 1, 0}
  def next_space(_space, _row_count, _col_count), do: nil

  defp completion_count(matches) do
    Enum.count(matches, fn {_neighbor, maybe_match} -> maybe_match end)
  end

  def matching_neighbors(data, matches, space) do
    current_rep = Map.get(data, space)

    # for neighbors in matches with truthy value
    new_matches =
      matches
      |> Enum.filter(fn {_neighbor_delta, maybe_match} ->
        maybe_match || current_rep in [1, 4]
      end)
      |> Enum.reduce([], fn {neighbor_delta, maybe_match}, acc ->
        inv_neighbor_delta = Common.pos_inv(neighbor_delta)
        inv_neighbor_space = Common.pos_add(space, inv_neighbor_delta)
        inv_neighbor_rep = Map.get(data, inv_neighbor_space)

        # IO.puts("current #{current_rep} delta #{inspect(neighbor_delta)} neighbor #{inv_neighbor_rep}")

        # if data[neighbor] is subsequent to data[space]
        if inv_neighbor_rep do
          diff = current_rep - inv_neighbor_rep

          if current_rep in [1, 4] do
            if diff in [1, -1] do
              [{neighbor_delta, diff} | acc]
            else
              acc
            end
          else
            if diff == maybe_match do
              # add neighbor to result set
              # IO.inspect(neighbor_delta, label: "Adding for space #{inspect(space)}")
              [{neighbor_delta, diff} | acc]
            else
              acc
            end
          end
        else
          acc
        end
      end)

    if space == {1, 3} do
      IO.inspect(matches, label: "incoming matches for {1, 3}")
      IO.inspect(new_matches, label: "new matches for {1, 3}")
    end

    new_matches
  end

  def continue_matches(acc, space, matches_to_continue) do
    # PROBLEM
    # This has no sense of orientation. i.e. XMX will see a match in the right direction
    # and continue it.
    # IO.puts("Continuing matches #{inspect(matches_to_continue)} for space #{inspect(space)}")
    new_acc =
      Enum.reduce(matches_to_continue, acc, fn {neighbor_delta, diff}, acc ->
        inv_neighbor_delta = Common.pos_inv(neighbor_delta)
        inv_neighbor = Common.pos_add(space, inv_neighbor_delta)

        # IO.puts("inv delta and inv neighbor #{inspect(inv_neighbor_delta)} #{inspect(inv_neighbor)}")

        if Map.has_key?(acc, inv_neighbor) do
          if inv_neighbor == {2, 2} do
            IO.puts("Setting {2, 2} to true from space #{inspect(space)}")
          end

          put_in(acc, [inv_neighbor, neighbor_delta], diff)
        else
          acc
        end
      end)

    new_acc
  end

  def xmas_count(data, row_count, col_count) do
    xmas_count(data, row_count, col_count, {0, 0}, build_acc(row_count, col_count), 0)
  end

  defp xmas_count(_data, _row_count, _col_count, nil, _acc, total), do: total

  defp xmas_count(data, row_count, col_count, space, acc, total) do
    rep = Map.get(data, space)
    matches = Map.get(acc, space)

    # if match?({3, _c}, space) do
    #   dbg(space)
    #   dbg(matches)
    # end

    new_total =
      if rep in [1, 4] do
        # check if there are any completed matches to add to total
        new_completions = completion_count(matches)

        # if new_completions > 0, do: IO.inspect(new_completions, label: "Adding completions for space #{inspect(space)}")
        total + new_completions
      else
        total
      end

    # check if there are in-progress matches to continue
    # should handle X/S and M/A cases
    matches_to_continue = matching_neighbors(data, matches, space)
    new_acc = continue_matches(acc, space, matches_to_continue)

    next_space = next_space(space, row_count, col_count)
    xmas_count(data, row_count, col_count, next_space, new_acc, new_total)
  end

  def part1(input) do
    {data, row_count, col_count} = parse_input(input)

    # IDEA
    # - Assign to each space a data structure with 8 attributes, representing neighbors.
    # - Iterate over input rows -> columns
    # - If an X or an S is encountered and, add its count of subsequent neighbor indicators
    #   to the total
    # - For each space, if it is indicated to have all necessary subsequent neighbors
    #   in any direction, and if the opposite direction contains the correct next value,
    #   update the structure with the next neighbor to indicate a possible XMAS

    xmas_count(data, row_count, col_count)
  end
end
