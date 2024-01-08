defmodule CamelCards do
  def organize_data(list) do
    for item <- list do
      String.split(item) |> List.to_tuple()
    end
  end

  def get_total_winnings(list, with_jokers) do
    sorted_hand = cond do
      with_jokers == false -> sort_hands_by_strength(list)
      with_jokers == true -> sort_hands_by_strength(list, 0)
    end |> Enum.with_index(1)
    for item <- sorted_hand, reduce: 0 do
      acc -> acc + String.to_integer(elem(item, 0) |> elem(1)) * elem(item, 1)
    end
  end

  defp sort_hands_by_strength(list, joker \\ 10)
  defp sort_hands_by_strength(list, joker) do
    List.keysort(list, 0, &(compare_hands(&1 |> String.to_charlist(),
    &2 |> String.to_charlist, joker)))
  end

  defp compare_hands(first, second, joker) do
    {left, right} = cond do
      joker == 0 -> {convert_jokers(first), convert_jokers(second)}
      joker != 0 -> {get_hand_strength(first), get_hand_strength(second)}
    end
    cond do
      left == right -> compare_labels(first, second, joker)
      left > right -> false
      left < right -> true
    end
  end

  defp joker_exists?(charlist), do: Enum.any?(charlist, &(&1 == ?J))
  defp convert_jokers(charlist) do
    chars = Enum.frequencies(charlist)
    max = cond do
      Enum.count(chars) > 1 ->
        chars |> Map.delete(?J) |> Enum.max_by(&(&1 |> elem(1)))
      Enum.count(chars) == 1 ->
        chars |> Enum.max_by(&(&1 |> elem(1)))
    end
    if joker_exists?(charlist) && max |> elem(0) != ?J do
      updated_max = elem(max, 1) + chars[?J]
      updated_map = chars |> Map.replace(max |> elem(0), updated_max) |>
        Map.delete(?J)
      convert_to_hand(updated_map)
    else
      get_hand_strength(charlist)
    end
  end

  defp get_hand_strength(charlist) do
    convert_to_hand(Enum.frequencies(charlist))
  end

  defp convert_to_hand(frequencies_map) do
    repetition_values = frequencies_map |> Map.values() |> Enum.sort(:desc)
    hand_string = for value <- repetition_values, reduce: "" do
      acc -> acc <> to_string(value)
    end
    hand_strength_map()[hand_string]
  end

  defp compare_labels([first | next_labels], [second | remaining_labels], joker) do
    {left, right} = {label_strength_map(joker)[first], label_strength_map(joker)[second]}
    cond do
      left == right -> compare_labels(next_labels, remaining_labels, joker)
      left > right -> false
      left < right -> true
    end
  end
  defp compare_labels([],[], _joker), do: false

  defp label_strength_map(joker) do
    %{?A => 13, ?K => 12, ?Q => 11, ?J => joker, ?T => 9, ?9 => 8, ?8 => 7,
    ?7 => 6, ?6 => 5, ?5 => 4, ?4 => 3, ?3 => 2, ?2 => 1}
  end
  defp hand_strength_map do
    %{"5" => 7, "41" => 6, "32" => 5, "311" => 4, "221" => 3, "2111" => 2,
    "11111" => 1}
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split(["\r\n", "\n"])
hand_list = CamelCards.organize_data(content_list)
IO.puts(inspect(CamelCards.get_total_winnings(hand_list, false)))
IO.puts(inspect(CamelCards.get_total_winnings(hand_list, true)))
