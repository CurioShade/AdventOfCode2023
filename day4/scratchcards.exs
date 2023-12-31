defmodule Scratchcards do
  def transform_cards(list) do
    tuple_list = for item <- list do
      tuple = String.replace(item, ~r/(Card )/, "")
        |> String.trim() |> String.split(":") |> List.to_tuple()
      {elem(tuple, 0) |> String.to_integer(), elem(tuple, 1)}
    end
    for item <- tuple_list, into: %{} do
      list = elem(item, 1) |> String.split("|") |> transform_to_points()
      {elem(item, 0), list}
    end
  end

  def sum_matched_points(map) do
    matched_list = get_matched_list(Map.values(map))
    for item <- matched_list do
      case Enum.count(item) do
        x when x > 0 -> 2**(x-1)
        x -> x
      end
    end |> Enum.sum()
  end

  def process_cards(map, accumulator_map, accumulator) when
  length(accumulator_map) > 0 do
    tuple_list = for item <- accumulator_map do
      for {key, value} <- item do
        {key, get_winning_numbers(hd(value), tl(value) |> List.flatten())
        |> Enum.count()}
      end
    end |> List.flatten()

    new_cards = for item <- tuple_list, elem(item, 1) > 0 do
      {key, range} = {elem(item, 0), elem(item,1)}
      range_list = Range.new(key+1, key+range) |> Range.to_list()
      for num <- range_list do
        %{num => map[num]}
      end
    end |> List.flatten()

    process_cards(map, new_cards, accumulator + Enum.count(accumulator_map))
  end

  def process_cards(_map, [], accumulator) do
    accumulator
  end

  def nest_card_map(map) do
    for {key, item} <- map do
      %{key => item}
    end
  end

  defp get_matched_list(list) do
    for item <- list do
      get_winning_numbers(hd(item), tl(item) |> List.flatten())
    end
  end

  defp get_winning_numbers(winning_list, owned_list) do
    for item <- owned_list, item in winning_list, do: item
  end

  defp transform_to_points(list) do
    for item <- list do
      String.split(item)
    end
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split("\n")
cards_map = Scratchcards.transform_cards(content_list)
nested_map = Scratchcards.nest_card_map(cards_map)
IO.puts(inspect(Scratchcards.sum_matched_points(cards_map)))
IO.puts(inspect(Scratchcards.process_cards(cards_map, nested_map, 0)))
