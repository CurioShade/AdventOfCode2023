defmodule Trebuchet do
  def sum_calibration(string_list) do
    Enum.reduce(string_list, 0, fn item, acc ->
      String.to_integer(item) + acc
    end)
  end

  def get_calibration(string_list) do
    for item <- string_list do
      digit_string = Regex.replace(~r/\D+/, item, "")
      String.first(digit_string) <> String.last(digit_string)
    end
  end

  def replace_digit_strings(string_list) do
    for item <- string_list do
      transform_digit_strings(item)
    end
  end

  defp transform_digit_strings(string) do
    Enum.reduce(atoms_to_strings(Map.keys(digit_map())), string, fn item, acc ->
      String.replace(acc, item, fn digit -> digit_map()[String.to_atom(digit)] end)
    end)
  end

  defp atoms_to_strings(atom_list) do
    for item <- atom_list, do: Atom.to_string(item)
  end

  defp digit_map do
    %{one: "o1e", two: "t2o", three: "t3e", four: "f4", five: "f5e", six: "s6",
    seven: "s7n", eight: "e8t", nine: "n9e"}
  end
end

file_name = String.trim(IO.gets("Give file_name: "))
{:ok, content} = File.read("#{file_name}")
content_list = String.split(content)
parsed_list = Trebuchet.replace_digit_strings(content_list)
string_list = Trebuchet.get_calibration(parsed_list)
calibration_sum = Trebuchet.sum_calibration(string_list)
IO.puts(inspect(calibration_sum))
