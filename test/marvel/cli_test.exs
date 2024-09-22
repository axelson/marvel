defmodule Marvel.CLI.Test do
  use ExUnit.Case, async: true

  alias Marvel.Test.MockHelpers

  alias Marvel.API.Characters
  # alias Marvel.API.Comics
  # alias Marvel.API.Creators
  # alias Marvel.API.Events
  # alias Marvel.API.Series
  # alias Marvel.API.Stories

  test "Characters string" do
    MockHelpers.mock_successful_response("characters_get")

    output =
      capture_output(fn ->
        Marvel.CLI.Utils.process_results(
          Characters.get(123),
          &Marvel.CLI.Utils.format_character_output/1
        )
      end)

    # IO.puts("output:")
    # IO.puts(output)

    assert output =~ "Name: 3-D Man"
    assert output =~ "ID: 1011334"
    assert output =~ "Description: "
    assert output =~ "Comics: 12"
    assert output =~ "Series: 3"
    assert output =~ "Stories: 21"
    assert output =~ "Events: 1"
    assert output =~ "Image: http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg"
  end

  test "Characters get json" do
    MockHelpers.mock_successful_response("characters_get")

    output =
      capture_output(fn ->
        Marvel.CLI.Utils.process_results(
          Characters.get(123),
          &Marvel.CLI.Utils.format_character_output/1,
          :print_json
        )
      end)

    assert Jason.decode!(output) == %{
             "meta" => %{
               "attribution" => "Data provided by Marvel. © 2023 MARVEL",
               "count" => 1,
               "limit" => 20,
               "offset" => 0,
               "total" => 1
             },
             "results" => [
               %{
                 "Comics" => 12,
                 "Description" => "",
                 "Events" => 1,
                 "ID" => 1_011_334,
                 "Image" => "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg",
                 "Name" => "3-D Man",
                 "Series" => 3,
                 "Stories" => 21
               }
             ]
           }
  end

  test "Characters list json" do
    MockHelpers.mock_successful_response("characters_list")

    output =
      capture_output(fn ->
        Marvel.CLI.Utils.process_results(
          Characters.list(),
          &Marvel.CLI.Utils.format_character_output/1,
          :print_json
        )
      end)

    assert Jason.decode!(output) == %{
             "meta" => %{
               "attribution" => "Data provided by Marvel. © 2023 MARVEL",
               "count" => 1,
               "limit" => 1,
               "offset" => 0,
               "total" => 1562
             },
             "results" => [
               %{
                 "Comics" => 12,
                 "Description" => "",
                 "Events" => 1,
                 "ID" => 1_011_334,
                 "Image" => "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg",
                 "Name" => "3-D Man",
                 "Series" => 3,
                 "Stories" => 21
               }
             ]
           }
  end

  defp capture_output(fun) when is_function(fun, 0) do
    ExUnit.CaptureIO.capture_io(fun)
    |> strip_ansi()
  end

  defp strip_ansi(text) do
    Regex.replace(~r/\e\[[0-9;]*[mGKH]/, text, "")
  end
end
