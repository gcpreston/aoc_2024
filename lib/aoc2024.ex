defmodule Aoc2024 do
  @input_path "./input"

  @spec input_for(integer()) :: String.t()
  def input_for(day) do
    padded_day =
      Integer.to_string(day)
      |> String.pad_leading(2, "0")

    {:ok, content} =
      Path.join(@input_path, padded_day <> ".txt")
      |> File.read()

    content
  end
end
