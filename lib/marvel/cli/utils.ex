defmodule Marvel.CLI.Utils do
  @moduledoc false

  require Jason.Helpers

  @default_output_config :print_lines

  def process_results(
        result,
        format_fn,
        output_config \\ Process.get(:output_config, @default_output_config)
      ) do
    case result do
      {:ok, response} ->
        case output_config do
          :print_lines ->
            print_attribution(response)

            for result <- response["data"]["results"], lines = format_fn.(result) do
              lines
              |> Enum.map(fn {header, value} -> format_row(header, value) end)
            end
            |> Enum.join("\n\n")
            |> IO.puts()

          :print_json ->
            %{
              meta: meta_json(response),
              results:
                for result <- response["data"]["results"], lines = format_fn.(result) do
                  lines
                  |> Jason.OrderedObject.new()
                end
            }
            |> Jason.encode!(pretty: true)
            |> IO.puts()
        end

      {:error, body} ->
        case output_config do
          :print_lines ->
            IO.puts(body["message"])

          :print_json ->
            {:error, %{message: body["message"]}}
            |> Jason.encode!(pretty: true)
            |> IO.puts()
        end
    end
  end

  def meta_json(data) do
    %{
      attribution: data["attributionText"],
      offset: data["data"]["offset"],
      limit: data["data"]["limit"],
      total: data["data"]["total"],
      count: data["data"]["count"]
    }
  end

  def print_attribution(data) do
    print_metadata("#{data["attributionText"]}")

    offset = data["data"]["offset"]
    limit = data["data"]["limit"]
    total = data["data"]["total"]
    count = data["data"]["count"]

    print_metadata("offset: #{offset} limit: #{limit} total: #{total} count: #{count}")
    print_end()
  end

  def format_character_output(character) do
    id = character["id"]
    name = character["name"]
    description = character["description"]
    comics_available = character["comics"]["available"]
    series_available = character["series"]["available"]
    stories_available = character["stories"]["available"]
    events_available = character["events"]["available"]

    image = format_thumbnail(character["thumbnail"])

    [
      {"Name", name},
      {"ID", id},
      {"Description", description},
      {"Comics", comics_available},
      {"Series", series_available},
      {"Stories", stories_available},
      {"Events", events_available},
      {"Image", image}
    ]
  end

  def format_comic_output(comic) do
    id = comic["id"]
    title = comic["title"]
    description = comic["description"]
    isbn = comic["isbn"]
    page_count = comic["pageCount"]

    series = comic["series"]["name"]
    creators = format_items(comic["creators"]["items"])
    characters = format_items(comic["characters"]["items"])
    stories = format_items(comic["stories"]["items"])
    events = format_items(comic["events"]["items"])

    image = format_thumbnail(comic["thumbnail"])

    [
      {"Title", title},
      {"ID", id},
      {"Description", description},
      {"ISBN", isbn},
      {"Page Count", page_count},
      {"Creators", creators},
      {"Characters", characters},
      {"Series", series},
      {"Stories", stories},
      {"Events", events},
      {"Image", image}
    ]
  end

  def format_event_output(event) do
    id = event["id"]
    title = event["title"]
    description = event["description"]
    start = event["start"]
    the_end = event["end"]

    stories = format_items(event["stories"]["items"])
    comics = format_items(event["comics"]["items"])
    series = format_items(event["series"]["items"])
    characters = format_items(event["characters"]["items"])
    creators = format_items(event["creators"]["items"])

    image = format_thumbnail(event["thumbnail"])

    [
      {"Title", title},
      {"ID", id},
      {"Description", description},
      {"Start", start},
      {"End", the_end},
      {"Stories", stories},
      {"Comics", comics},
      {"Series", series},
      {"Characters", characters},
      {"Creators", creators},
      {"Image", image}
    ]
  end

  def format_series_output(series) do
    id = series["id"]
    title = series["title"]
    description = series["description"]
    start_year = series["start_year"]
    end_year = series["end_year"]
    rating = series["rating"]

    stories = format_items(series["stories"]["items"])
    comics = format_items(series["comics"]["items"])
    events = format_items(series["events"]["items"])
    characters = format_items(series["characters"]["items"])
    creators = format_items(series["creators"]["items"])

    image = format_thumbnail(series["thumbnail"])

    [
      {"Title", title},
      {"ID", id},
      {"Description", description},
      {"Start Year", start_year},
      {"End Year", end_year},
      {"Rating", rating},
      {"Stories", stories},
      {"Comics", comics},
      {"Events", events},
      {"Characters", characters},
      {"Creators", creators},
      {"Image", image}
    ]
  end

  def format_story_output(story) do
    id = story["id"]
    title = story["title"]
    description = story["description"]
    type = story["type"]

    comics = format_items(story["comics"]["items"])
    series = format_items(story["series"]["items"])
    events = format_items(story["events"]["items"])
    characters = format_items(story["characters"]["items"])
    creators = format_items(story["creators"]["items"])

    image = format_thumbnail(story["thumbnail"])

    [
      {"Title", title},
      {"ID", id},
      {"Description", description},
      {"Type", type},
      {"Comics", comics},
      {"Series", series},
      {"Events", events},
      {"Characters", characters},
      {"Creators", creators},
      {"Image", image}
    ]
  end

  def format_creator_output(creator) do
    id = creator["id"]
    name = creator["fullName"]

    comics = format_items(creator["comics"]["items"])
    series = format_items(creator["series"]["items"])
    events = format_items(creator["events"]["items"])
    stories = format_items(creator["stories"]["items"])

    image = format_thumbnail(creator["thumbnail"])

    [
      {"Name", name},
      {"ID", id},
      {"Comics", comics},
      {"Series", series},
      {"Events", events},
      {"Stories", stories},
      {"Image", image}
    ]
  end

  defp print_end() do
    "" |> IO.puts()
    "" |> IO.puts()
  end

  defp format_row(key, value) do
    IO.ANSI.format([:red, "#{key}: ", :white, "#{value}", "\n"], true)
  end

  defp print_metadata(meta) do
    IO.puts(IO.ANSI.format([:yellow, "#{meta}"], true))
  end

  def format_items(items) do
    Enum.map(items, fn x ->
      id = x["resourceURI"] |> String.split("/") |> List.last()
      name = x["name"]

      "#{name} (#{id})"
    end)
    |> Enum.join(", ")
  end

  def format_thumbnail(nil) do
    ""
  end

  def format_thumbnail(thumbnail) do
    thumbnail["path"] <> "." <> thumbnail["extension"]
  end
end
