defmodule Pipe do
  defstruct [:type, name: "", siblings: []]
end

defmodule Maze do
  def organize_pipes(list) do
    for item <- list do
      item |> String.to_charlist() |> Enum.with_index() |>
        Enum.into(%{}, fn record ->
          {elem(record, 1), elem(record, 0)}
        end)
    end |> Enum.with_index() |>
    Enum.into(%{}, fn record ->
    {elem(record, 1), elem(record, 0)} end) |>
    transform_data_to_pipe()
  end

  def get_maze_distance(pipe_map) do
    start = find_maze_start(pipe_map)
    if start != nil do
      number = get_main_loop_pipes(pipe_map, start, start) |> Enum.count()
      (number + 1) |> div(2)
    else
      0
    end
  end

  def get_main_loop_pipes(pipe_map, current_indexes, previous_indexes, accumulator \\ [])
  def get_main_loop_pipes(pipe_map, current_indexes, previous_indexes, accumulator) do
    pipe = get_in(pipe_map, current_indexes |> Tuple.to_list())
    new_indexes = pipe.siblings |> Enum.reject(fn indexes ->
      indexes == previous_indexes
    end)
    unless Enum.empty?(new_indexes) do
      get_main_loop_pipes(pipe_map, new_indexes |> hd(), current_indexes, [current_indexes | accumulator])
    else
      accumulator
    end
  end

  def find_maze_start(pipe_map) do
    Enum.find_value(pipe_map, fn {column, column_value} ->
      pipe = Enum.find(column_value, fn {_, pipe} -> pipe.name == ?S end)
      if pipe != nil, do: {column, elem(pipe, 0)}, else: nil
    end)
  end

  def transform_data_to_pipe(pipe_map) do
    for {column, column_value} <- pipe_map do
      row_pipes = for {row, pipe} <- column_value do
        if pipe != ?. do
          pipes_list = get_surrounding_pipes(pipe_map, {column, row})
          responding_key = Map.has_key?(possible_siblings(), pipe)
          type = case responding_key do
            true -> pipe
            false -> uncover_start_pipe(pipes_list)
          end
          connections = possible_siblings()[type]
          siblings = get_tuple_matches(pipes_list, connections, connections)
          indexed_siblings = for {_k, indexes} <- siblings, do:
            {column + elem(indexes, 0), row + elem(indexes, 1)}
          {row, %Pipe{name: pipe, type: type, siblings: indexed_siblings}}
        end
      end |> Enum.reject(&(&1 == nil)) |> transform_to_hash()
      {column, row_pipes}
    end |> Enum.reject(&(&1 == nil)) |>
    Enum.reject(&(map_size(elem(&1, 1)) == 0)) |> transform_to_hash()
  end

  def uncover_start_pipe(pipes_list) do
    Enum.find(Map.keys(possible_siblings()), fn key ->
      connections = possible_siblings()[key]
      get_tuple_matches(pipes_list, connections, connections) |>
        length() == 2
    end)
  end

  def get_surrounding_pipes(pipe_map, indexes) do
    {column, row} = indexes
    for index <- [{column-1, row}, {column, row-1}, {column+1, row}, {column, row+1}] do
      {first, second} = index
      distance = {first - column, second - row}
      {get_in(pipe_map, [first, second]), distance}
    end |> Enum.reject(&(elem(&1, 0) == nil)) |> Enum.reject(&(elem(&1, 0) == ?.))
  end

  def get_tuple_matches(match_list, search_list, search_copy, accumulator \\ [])
  def get_tuple_matches(match_list, search_list, search_copy, accumulator) when
  length(search_list) > 0 and length(match_list) > 0 do
    {pipe, tuples_list} = hd(search_list)
    {_, indexes} = hd(match_list)
    case {pipe, get_sibling_pipe(tuples_list, indexes)} === hd(match_list) do
      true -> get_tuple_matches(tl(match_list), search_copy, search_copy,
      [hd(match_list) | accumulator])
      false -> get_tuple_matches(match_list, tl(search_list), search_copy,
      accumulator)
    end
  end

  def get_tuple_matches(match_list, _search_list, search_copy, accumulator) do
    if length(match_list) == 0 do
      accumulator
    else
      get_tuple_matches(tl(match_list), search_copy, search_copy, accumulator)
    end
  end

  def get_sibling_pipe(tuples_list, indexes_tuple) do
    Enum.find(tuples_list, &(&1 == indexes_tuple))
  end

  def possible_siblings do
    %{?| => [{?F, [{-1, 0}]}, {?L, [{1, 0}]}, {?J, [{1, 0}]}, {?7, [{-1, 0}]}, {?|, [{-1, 0}, {1, 0}]}],
    ?- => [{?F, [{0, -1}]}, {?7, [{0, 1}]}, {?L, [{0, -1}]}, {?J, [{0, 1}]}, {?-, [{0, -1}, {0, 1}]}],
    ?F => [{?-, [{0, 1}]}, {?7, [{0, 1}]}, {?|, [{1, 0}]}, {?L, [{1, 0}]}, {?J, [{1, 0}, {0, 1}]}],
    ?7 => [{?-, [{0, -1}]}, {?F, [{0, -1}]}, {?|, [{1, 0}]}, {?J, [{1, 0}]}, {?L, [{1, 0}, {0, -1}]}],
    ?L => [{?|, [{-1, 0}]}, {?F, [{-1, 0}]}, {?7, [{-1, 0}, {0, 1}]}, {?-, [{0, 1}]}, {?J, [{0, 1}]}],
    ?J => [{?|, [{-1, 0}]}, {?7, [{-1, 0}]}, {?F, [{-1, 0}, {0, -1}]}, {?-, [{0, -1}]}, {?L, [{0, -1}]}]}
  end

  defp transform_to_hash(collection) do
    Enum.into(collection, %{}, fn {index, item} ->
      {index, item}
    end)
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split(["\r\n", "\n"])
pipes_data = Maze.organize_pipes(content_list)
IO.puts(inspect(Maze.get_maze_distance(pipes_data)))
