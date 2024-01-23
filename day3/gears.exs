defmodule Gears do
  def process_data(list) do
    list |>
      Enum.map(fn item ->
        Regex.scan(~r/\.{1,}|\d{1,}|(?=[^.])\D/, item) |> List.flatten()
      end) |>
      Enum.with_index() |>
      Enum.into(%{}, fn record ->
        {elem(record, 1), elem(record, 0)}
      end)
  end

  def sum_part_numbers(gears_data, sum_ratio \\ false)
  def sum_part_numbers(gears_data, sum_ratio) do
    get_part_numbers(gears_data, sum_ratio) |>
      Enum.sum()
  end

  defp get_part_numbers(gears_data, sum_ratio) do
    for { key, value } <- gears_data do
      symbol_positions = get_position_from_regex(~r/(?=[^.])\D/, value)
      unless symbol_positions == nil do
        process_symbol_data(symbol_positions, key, gears_data, sum_ratio)
      end
    end |> List.flatten() |> Enum.reject(&(&1 == nil))
  end

  defp process_symbol_data(positions, key, gears_data, search_for_gear) do
    if search_for_gear do
      for position <- positions do
        if elem(position, 0) =~ "*" do
          digits = get_symbol_data(position |> elem(1), key, gears_data) |>
            List.flatten() |> Enum.reject(&(&1 == nil))
          if length(digits) == 2 do
            ratio_tuple = digits |> List.to_tuple()
            elem(ratio_tuple, 0) * elem(ratio_tuple, 1)
          end
        end
      end
    else
      for position <- positions do
        get_symbol_data(position |> elem(1), key, gears_data)
      end
    end
  end

  defp get_symbol_data(symbol_position, key, gears_map) do
    for index <- [key-1, key, key+1] do
      digit_positions = get_position_from_regex(~r/\d{1,}/, gears_map[index])
      unless digit_positions == nil do
        for tuple <- digit_positions do
          {element, position, size} = tuple
          if position >= symbol_position - size && position <= symbol_position + 1 do
            element |> String.to_integer()
          end
        end
      end
    end
  end

  defp get_elements_data(elements_list, list, position \\ 0, accumulator \\ [])
  defp get_elements_data(elements_list, list, position, accumulator) when
  length(elements_list) > 0 and length(list) > 0 do
    element = hd(elements_list)
    [head | tail] = list
    if element =~ head do
      element_data = {element, position, String.length(element)}
      get_elements_data(tl(elements_list), tail, position + elem(element_data, 2),
      [element_data | accumulator])
    else
      get_elements_data(elements_list, tail, position + String.length(head), accumulator)
    end
  end

  defp get_elements_data(_elements_list, _list, _position, accumulator) do
    accumulator
  end

  defp get_position_from_regex(regex, list) do
    matches = Enum.filter(list, &(&1 =~ regex))
    unless Enum.empty?(matches) do
      get_elements_data(matches, list)
    end
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = content |> String.trim() |> String.split(["\r\n", "\n"])
gears_data = Gears.process_data(content_list)
IO.puts(inspect(Gears.sum_part_numbers(gears_data, false)))
IO.puts(inspect(Gears.sum_part_numbers(gears_data, true)))
