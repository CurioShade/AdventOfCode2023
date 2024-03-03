defmodule AStar do
  @moduledoc """
  A search implementation for Elixir
  """
  def find_path(map, start, finish) do
    open_list = PriorityQueue.new() |> PriorityQueue.put({0, start})
    closed_map = %{start => nil}
    cost_map = %{start => 0}
    path_map = traverse_path(map, open_list, closed_map, cost_map, finish)
    rebuild_path(path_map, start, finish)
  end

  defp traverse_path(map, open_list, closed_map, cost_map, finish) when
  open_list.size > 0 do
    current = open_list |> PriorityQueue.min() |> elem(1)
    open_list = PriorityQueue.delete_min(open_list)
    if current == finish do
      closed_map
    else
      points = {current, finish}
      path_data = traverse_siblings(get_siblings(map, current), open_list,
      closed_map, cost_map, points)
      {open_list, closed_map, cost_map} = path_data
      traverse_path(map, open_list, closed_map, cost_map, finish)
    end
  end

  defp traverse_path(_map, _open_list, closed_map, _cost_map, _finish) do
    closed_map
  end

  defp traverse_siblings([node | other_nodes], open_list, closed_map, cost_map,
  points) do
    {current, finish} = points
    new_cost = cost_map[current] + 1
    if node not in Map.keys(cost_map) || new_cost < Map.get(cost_map, node) do
      priority = new_cost + heuristics(node, finish)
      sibling = {priority, node}
      traverse_siblings(other_nodes,
        PriorityQueue.put(open_list, sibling),
        Map.put(closed_map, node, current),
        Map.put(cost_map, node, new_cost),
        points)
    else
      traverse_siblings(other_nodes, open_list, closed_map, cost_map, points)
    end
  end

  defp traverse_siblings([], open_list, closed_map, cost_map, _points) do
    {open_list, closed_map, cost_map}
  end

  defp rebuild_path(map, start, finish) do
    if finish not in Map.keys(map) do
      []
    else
      get_path_from_map(map, start, finish)
    end
  end

  defp get_path_from_map(map, start, current, accumulator \\ [])
  defp get_path_from_map(map, start, current, accumulator) do
    if current != start do
      get_path_from_map(map, start, map[current], [current | accumulator])
    else
      accumulator
    end
  end

  defp heuristics(current_cell, goal) do
    {cell_y, cell_x} = current_cell
    {goal_y, goal_x} = goal
    abs(cell_x - goal_x) + abs(cell_y - goal_y)
  end

  defp get_siblings(map, index) do
    {column, row} = index
    for sibling <- [{column-1, row}, {column, row-1}, {column+1, row},
    {column, row+1}], get_in(map, sibling |> Tuple.to_list()) != nil do
      sibling
    end
  end
end
