defmodule Cubes do
  def organize_games(list) do
    games_list = for item <- list, do: List.to_tuple(String.split(item, ":"))
    for item <- games_list, into: %{} do {
      String.to_integer(String.replace(elem(item, 0), ["Game ", ":"], "")),
      transform_to_tuple(String.split(String.trim(elem(item, 1)), ~r/,|;/))
    }
    end
  end

  def sum_games(map) do
    filtered_map = exclude_incorrect_games(map)
    for {key, _item} <- filtered_map, reduce: 0 do
      acc -> key + acc
    end
  end

  def multiply_possible_games(map) do
    games_map = get_possible_games(map)
    for item <- games_map, reduce: 0 do
      acc -> item[:red] * item[:green] * item[:blue] + acc
    end
  end

  defp get_possible_games(map) do
    for {_k, item} <- map do
      transform_to_possible_game(item)
    end
  end

  defp transform_to_possible_game(list) do
    for item <- list, reduce: %{red: 0, green: 0, blue: 0} do
      acc -> Map.update!(acc, elem(item, 1), fn current_value ->
        max(elem(item, 0), current_value)
      end)
    end
  end

  defp exclude_incorrect_games(map) do
    Map.filter(map, fn {_k, value} ->
      Enum.all?(value, fn item ->
        cubes_not_above_max(item)
      end)
    end)
  end

  defp transform_to_tuple(list) do
    for item <- list do
      tuple = List.to_tuple(String.split(item))
      {elem(tuple, 0) |> String.to_integer(), elem(tuple, 1) |> String.to_atom()}
    end
  end
  defp cubes_not_above_max(tuple), do: elem(tuple, 0) <= cubes_max()[elem(tuple, 1)]
  defp cubes_max, do: %{red: 12, green: 13, blue: 14}
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.split(content, "\n")
games_map = Cubes.organize_games(content_list)
IO.puts(inspect(Cubes.sum_games(games_map)))
IO.puts(inspect(Cubes.multiply_possible_games(games_map)))
