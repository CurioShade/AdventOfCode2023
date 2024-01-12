defmodule Oasis do
  def organize_data(list) do
    for item <- list do
      item |> String.split() |> Enum.map(fn str -> String.to_integer(str) end)
    end
  end

  def extrapolate_values(numbers_list, move_backwards \\ false)
  def extrapolate_values(numbers_list, move_backwards) do
    for list <- numbers_list do
      calculate_extrapolation(list, move_backwards)
    end |> Enum.sum()
  end

  defp calculate_extrapolation(numbers_list, move_backwards) do
    lists = process_sequence(numbers_list, [numbers_list])
    if move_backwards do
      for list <- lists, reduce: 0 do
        acc -> List.first(list) - acc
      end
    else
      for list <- lists, reduce: 0 do
        acc -> List.last(list) + acc
      end
    end
  end

  defp process_sequence(numbers_list, accumulator) do
    difference = get_difference(numbers_list) |> Enum.reverse()
    case difference |> Enum.all?(fn num -> num == 0 end) do
      true -> [difference | accumulator]
      false -> process_sequence(difference, [difference | accumulator])
    end
  end

  defp get_difference(numbers_list) do
    [first | rest] = numbers_list
    calculate_difference(rest, first)
  end

  defp calculate_difference(numbers_list, previous, accumulator \\ [])
  defp calculate_difference([current | rest], previous, accumulator) do
    calculate_difference(rest, current, [current - previous | accumulator ])
  end
  defp calculate_difference([], _previous, accumulator), do: accumulator
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split(["\r\n", "\n"])
numbers = Oasis.organize_data(content_list)
IO.puts(inspect(Oasis.extrapolate_values(numbers)))
IO.puts(inspect(Oasis.extrapolate_values(numbers, true)))
