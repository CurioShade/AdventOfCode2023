defmodule Seeds do
  def organize_data(list) do
    seeds_list = hd(list) |> String.split("seeds: ")
    for item <- list |> List.delete_at(0), into: %{} do
      mapping_list = String.replace(item, [":", "map"], "") |>
        String.replace("-", "_") |> String.trim() |> String.split(["\r\n", "\n"])

      {hd(mapping_list) |> String.trim() |> String.to_atom,
      tl(mapping_list)}
    end |> Map.put(:seeds, tl(seeds_list) |> List.to_string())
  end

  def map_ranges(map) do
    for key <- Map.keys(map) |> List.delete_at(0), into: %{} do
      mapped_values = for item <- map[key] do
        ranges = for range <- String.split(item) do
          String.to_integer(range)
        end |> List.to_tuple()
        {destination, source, range} = ranges

        range_tuple = {Range.new(source, source+range-1),
          Range.new(destination, destination+range-1)}

        %{elem(range_tuple, 0) => elem(range_tuple, 1)}
      end |> List.flatten()

      {key, reduce_list_to_map(mapped_values)}
    end
  end

  def get_lowest_location(seeds, ranges_map) do
    for item <- seeds |> String.split() do
      get_location(ranges_map, item |> String.to_integer())
    end |> Enum.min()
  end

  def get_lowest_location_from_range(ranges_map, seeds) do
    seeds_range = range_seeds(seeds)
    value = for range <- seeds_range do
      get_location_range(ranges_map, range)
    end |> List.flatten() |> Enum.min()
    value.first
  end

  defp get_location(map, source) do
    for {_k, value} <- map, reduce: source do
      acc -> get_destination(value |> Map.keys(), value |> Map.values(), acc)
    end
  end

  defp get_location_range(map, source_range) do
    for {_k, value} <- map, reduce: [source_range] do
      acc -> get_destination_range(value, acc, [])
    end
  end

  defp get_destination([key | remaining_keys], [value | remaining_values], source) do
    if source in key do
      source - key.first + value.first
    else
      get_destination(remaining_keys, remaining_values, source)
    end
  end

  defp get_destination([], [], source) do
    source
  end

  defp get_destination_range(map, [range | other_ranges], accumulator) do
    source_range = get_source_range(Map.keys(map), range)
    if is_tuple(source_range) do
      {ranges, source} = source_range
      new_range = convert_range_to_another(hd(ranges), source, map[source])
      get_destination_range(map, tl(ranges) ++ other_ranges, [new_range | accumulator])
    else
      get_destination_range(map, other_ranges, [source_range | accumulator])
    end
  end

  defp get_destination_range(_map, [], accumulator) do
    accumulator
  end

  defp get_source_range([key | remaining_keys], range) do
    if Range.disjoint?(key, range) do
      get_source_range(remaining_keys, range)
    else
      {split_range_by_range(range, key), key}
    end
  end

  defp get_source_range([], range) do
    range
  end

  defp range_seeds(seeds_string) do
    seeds = Regex.scan(~r/(\w+ \w+)/, seeds_string, capture: :first) |> List.flatten()
    for seed <- seeds do
      seeds_list = seed |> String.split()

      seeds_tuple = for item <- seeds_list do
        String.to_integer(item)
      end |> List.to_tuple()
      {first, last} = seeds_tuple

      Range.new(first, first + last - 1)
    end
  end

  defp convert_range_to_another(range, source_range, destination_range) do
    {first, second} =
      {range.first - source_range.first, range.last - source_range.last}
    Range.new(destination_range.first + first, destination_range.last + second)
  end

  defp split_range_by_range(range1, range2) do
    cond do
      range1.last < range2.first || range1.first > range2.last ->
        nil
      range1.first >= range2.first && range1.last <= range2.last ->
        [range1]
      range1.first >= range2.first && range1.last > range2.last ->
        [Range.new(range1.first, range2.last), Range.new(range2.last+1, range1.last)]
      range1.first < range2.first && range1.last <= range2.last ->
        [Range.new(range2.first, range1.last), Range.new(range1.first, range2.first-1)]
      range1.first < range2.first && range1.last > range2.last ->
        [Range.new(range2.first, range2.last), Range.new(range1.first, range2.first-1),
        Range.new(range2.last+1, range1.last)]
      end
  end

  defp reduce_list_to_map(list) do
    for item <- list, reduce: %{} do
      acc -> Map.merge(item, acc)
    end
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split(["\r\n\r\n", "\n\n"])
almac_map = Seeds.organize_data(content_list)
ranges_map = Seeds.map_ranges(almac_map)
IO.puts(inspect(Seeds.get_lowest_location(almac_map[:seeds], ranges_map)))
IO.puts(inspect(Seeds.get_lowest_location_from_range(ranges_map, almac_map[:seeds])))
