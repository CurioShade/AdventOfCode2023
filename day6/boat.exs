defmodule Boat do
  def organize_data(list) do
    tuple = for item <- list do
      string_list = String.split(item) |> List.delete_at(0)
      for string <- string_list, do: String.to_integer(string)
    end |> List.to_tuple()
    Enum.zip(elem(tuple, 0), elem(tuple, 1))
  end

  def join_data(list) do
    string_list = for item <- list do
      String.split(item) |> List.delete_at(0)
    end
    for record <- string_list do
      Enum.reduce(record, fn string, acc -> acc <> string end)
      |> String.to_integer()
    end |> List.to_tuple()
  end

  def get_wins_for_one_race(tuple) do
    {time, distance} = tuple
    possible_wins(1, time, distance, []) |> Enum.count()
  end

  def get_all_possible_wins(list) do
    distance_list = for item <- list do
      {time, distance} = item
      possible_wins(1, time, distance, [])
    end
    for record <- distance_list do
      Enum.count(record)
    end |> Enum.reduce(fn number, acc -> number * acc end)
  end

  def calculate_distance(time_pressed, time) do
    time_pressed * (time-time_pressed)
  end

  def possible_wins(pressed, time, distance, accumulator) when time > pressed do
    passed_distance = calculate_distance(pressed, time)
    if passed_distance > distance do
      possible_wins(pressed+1, time, distance, [passed_distance | accumulator])
    else
      possible_wins(pressed+1, time, distance, accumulator)
    end
  end

  def possible_wins(_pressed, _time, _distance, accumulator) do
    accumulator
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.trim(content) |> String.split(["\r\n", "\n"])
records_data = Boat.organize_data(content_list)
joined_data = Boat.join_data(content_list)
IO.puts(inspect(Boat.get_all_possible_wins(records_data)))
IO.puts(inspect(Boat.get_wins_for_one_race(joined_data)))
