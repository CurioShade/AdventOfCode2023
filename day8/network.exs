defmodule Network do
  def organize_nodes(list) do
    instruction = hd(list)
    nodes = for item <- tl(list), into: %{} do
      node_tuple = item |> String.replace(~r/\(|\)/, "") |>
        String.split(" = ") |> List.to_tuple()
      pairs = node_tuple |> elem(1) |> String.split(", ") |> List.to_tuple()
      {node_tuple |> elem(0), pairs}
    end
    {instruction, nodes}
  end

  def start_multiple_traversals(organized_nodes) do
    direction = organized_nodes |> elem(0) |> String.to_charlist()
    nodes_map = organized_nodes |> elem(1)
    positions = get_starting_points(nodes_map)
    for item <- positions do
      traverse_nodes(direction, direction, item, nodes_map, 1, true)
    end |> Enum.reduce(fn node, acc -> calculate_lcm(acc, node) end)
  end

  def start_traversal(organized_nodes) do
    direction = organized_nodes |> elem(0) |> String.to_charlist()
    nodes = organized_nodes |> elem(1)
    traverse_nodes(direction, direction, "AAA", nodes, 1, false)
  end

  defp get_starting_points(nodes) do
    Stream.filter(nodes |> Map.keys(), fn key -> key =~ ~r/.{1,}A/ end)
  end

  defp traverse_nodes([direction | remaining_directions], direction_list,
  position, nodes, counter, match_end) do
    new_position = move_to_node(direction, position, nodes)
    case match_position(match_end, new_position) do
      true -> counter
      false -> traverse_nodes(remaining_directions, direction_list, new_position,
      nodes, counter+1, match_end)
    end
  end
  defp traverse_nodes([], direction_list, position, nodes, counter, match_end) do
    traverse_nodes(direction_list, direction_list, position, nodes, counter, match_end)
  end

  defp move_to_node(direction, position, nodes) do
    index = case direction do
      ?L -> 0
      ?R -> 1
    end
    nodes[position] |> elem(index)
  end

  defp match_position(match_end, position) do
    if match_end do
      position =~ ~r/.{1,}Z/
    else
      position == "ZZZ"
    end
  end

  defp calculate_lcm(a, b), do: div(a*b, calculate_gdc(a, b))

  defp calculate_gdc(a, b) do
    case b != 0 do
      true -> calculate_gdc(b, rem(a,b))
      false -> a
    end
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split(["\r\n", "\n"]) |>
  List.delete_at(1)
organized_nodes = Network.organize_nodes(content_list)
IO.puts(inspect(Network.start_traversal(organized_nodes)))
IO.puts(inspect(Network.start_multiple_traversals(organized_nodes)))
