defmodule ElixirJobs do
  @moduledoc false
  @url "https://elixirjobs.net"

  def get_jobs do
    {:ok, res} = HTTPoison.get(@url)

    res.body
    |> get_total
    |> Task.await_many(60_000)
    |> Utils.save_vacancies("elixir_jobs")
  end

  defp get_total(html) do
    {:ok, document} = Floki.parse_document(html)

    text =
      Floki.find(document, ".level-left > .level-item")
      |> Floki.text()
      |> String.trim()

    Regex.named_captures(~r/page (?<start>.*) of (?<end>.*)/, text)
    |> parse_values
    |> get_jobs
  end

  defp parse_values(%{"start" => start, "end" => endValue}),
    do: {String.to_integer(start), String.to_integer(endValue)}

  defp get_jobs({start, ed}),
    do:
      Enum.map(
        start..ed,
        fn page -> Task.async(fn -> get_page_urls(page) end) end
      )

  defp get_page_urls(vacancy) do
    {:ok, res} = HTTPoison.get(@url <> "/?page=#{vacancy}")
    {:ok, document} = Floki.parse_document(res.body)

    Floki.find(document, ".offers-index a")
    |> Floki.attribute("href")
    |> Enum.filter(fn url -> not String.contains?(url, "?page=") end)
    |> Enum.map(&get_page/1)
  end

  defp get_page(url) do
    {:ok, res} = HTTPoison.get(@url <> url)
    {:ok, document} = Floki.parse_document(res.body)
    content = Floki.find(document, ".content")

    %{
      title: get_title(content),
      body: Floki.find(document, ".body") |> Floki.text() |> String.trim(),
      details: get_details(content)
    }
  end

  defp get_title(html) do
    %{
      title:
        Floki.find(html, ".title > strong")
        |> Floki.text()
        |> String.trim(),
      company_and_local:
        Floki.find(html, ".title > small")
        |> Floki.text()
        |> String.trim()
    }
  end

  defp get_details(html) do
    workplace =
      Floki.find(html, ".is-warning")
      |> Floki.text()
      |> String.trim()

    %{
      date:
        Floki.find(html, ".is-danger")
        |> Floki.text()
        |> String.trim(),
      workplace: workplace,
      is_remote: workplace == "Remote",
      type:
        Floki.find(html, ".is-link")
        |> Floki.text()
        |> String.trim()
    }
  end
end
