defmodule Mix.Tasks.Aoc do
  @moduledoc "Run days and parts"
  @shortdoc ":)"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    [day, part] = args

    int_day = String.to_integer(day)
    formatted_day = String.pad_leading(day, 2, "0")
    input = Aoc2024.input_for(int_day)

    part_func = case part do
      "1" -> :part1
      "2" -> :part2
    end

    result = apply(String.to_existing_atom("Elixir.Aoc2024.Day#{formatted_day}"), part_func, [input])
    Mix.shell().info(to_string(result))
  end
end
