defmodule Cosmos do
  @moduledoc """
  Module containing functions that operate on Day 11 puzzle input data
  """
  def process_image(list) do
    row_size = list |> hd() |> String.length()
    for item <- list do
      item |> String.to_charlist()
    end |> expand_space(row_size) |> convert_list_to_map()
  end

  def sum_galaxies_paths(map, distance \\ 1)
  def sum_galaxies_paths(map, distance) do
    galaxies = find_galaxies_position(map)
    get_galaxies_distances(map, galaxies, tl(galaxies), distance) |> Enum.sum()
  end

  defp get_galaxies_distances(map, start_list, finish_list, distance, accumulator \\ [])
  defp get_galaxies_distances(map, start_list, [index | other_indexes], distance, accumulator) do
    path = AStar.find_path(map, hd(start_list), index)
    path_length = Enum.reduce(path, 0, fn item, acc ->
      get_distance(get_in(map, item |> Tuple.to_list()), distance) + acc
    end)
    get_galaxies_distances(map, start_list, other_indexes, distance, [path_length | accumulator])
  end

  defp get_galaxies_distances(map, start_list, [], distance, accumulator) do
    indexes = tl(start_list)
    if length(indexes) > 1 do
      get_galaxies_distances(map, indexes, tl(indexes), distance, accumulator)
    else
      accumulator
    end
  end

  defp find_galaxies_position(map) do
    for {column, column_value} <- map, {row, row_value} <- column_value,
    row_value != ?. && row_value != ?x do
      {column, row}
    end
  end

  defp expand_space(list, row_size) do
    rows_to_fill = seek_empty_rows(list)
    columns_to_fill = seek_empty_columns(list, row_size)
    for row <- rows_to_fill, reduce: list do
      acc -> List.insert_at(acc, row+1, List.duplicate(?x, row_size))
    end |> Enum.map(fn line ->
      for column <- columns_to_fill, reduce: line do
        acc -> List.insert_at(acc, column+1, ?x)
      end
    end)
  end

  defp seek_empty_columns(list, row_size) do
    for row <- 0..row_size-1 do
      empty_column = for line <- list do
        Enum.at(line, row)
      end |> Enum.all?(&(&1 == ?.))
      case empty_column do
        true -> row
        false -> nil
      end
    end |> Enum.reject(&(&1 == nil)) |> Enum.sort(:desc)
  end

  defp seek_empty_rows(list) do
    for {line, column} <- list |> Enum.with_index(),
    Enum.all?(line, &(&1 == ?.)) do
      column
    end |> Enum.sort(:desc)
  end

  defp convert_list_to_map(list) do
    for item <- list do
      item |> Enum.with_index() |> convert_tuples_to_map()
    end |> Enum.with_index() |> convert_tuples_to_map()
  end

  defp get_distance(item, distance) do
    cond do
      item == ?x -> distance
      item != ?x -> 1
    end
  end

  defp convert_tuples_to_map(tuple_list) do
    Enum.into(tuple_list, %{}, fn record ->
      {elem(record, 1), elem(record, 0)}
    end)
  end
end
