defmodule Budget do
  alias NimbleCSV.RFC4180, as: CSV

  def list_transactions do
    File.read!("lib/transactions.csv")
    |> parse
    |> filter
    |> normalize
    |> sort
    |> print
  end

  defp parse(content) do
    CSV.parse_string(content)
  end

  defp filter(rows) do
    Enum.map(rows, &Enum.drop(&1, 1))
  end

  defp normalize(rows) do
    Enum.map(rows, &parse_amount(&1))
  end

  defp parse_amount([date, description, amount]) do
    [date, description, float_abs_value(amount)]
  end

  defp float_abs_value(string) do
    string
    |> String.replace("\r", "")
    |> String.to_float
    |> abs
  end

  defp sort(rows) do
    Enum.sort(rows, &sort_asc_by_amount(&1, &2))
  end

  defp sort_asc_by_amount([_, _, first_amount], [_, _, second_amount]) do
    first_amount < second_amount
  end

  defp print(rows) do
    IO.puts("Transactions:")
    Enum.each(rows, &print_to_console(&1))
  end

  defp print_to_console([date, description, amount]) do
    IO.puts("#{date} #{description} \t $#{:erlang.float_to_binary(amount, decimals: 2)}")
  end
end
