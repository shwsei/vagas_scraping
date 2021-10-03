defmodule JobsScraping.ElixirJobs do
  @moduledoc false
  @url "https://elixirjobs.net"

  def get_jobs do
    alias JobsScraping.{Utils}

    {:ok, res} = HTTPoison.get(@url)

    res.body
    |> get_total
    |> Task.await_many(60_000)
    |> Enum.reduce(&(&2 ++ &1))
    |> Utils.save_jobs("elixir_jobs")
  end

  defp get_text(doc, filter) do
    Floki.find(doc, filter)
    |> Floki.text()
    |> String.trim()
  end

  defp get_total(html) do
    {:ok, doc} = Floki.parse_document(html)

    text = get_text(doc, ".level-left > .level-item")

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
    {:ok, doc} = Floki.parse_document(res.body)

    Floki.find(doc, ".offers-index a")
    |> Floki.attribute("href")
    |> Enum.filter(fn url -> not String.contains?(url, "?page=") end)
    |> Enum.map(&get_page/1)
  end

  defp get_page(url) do
    {:ok, res} = HTTPoison.get(@url <> url)
    {:ok, doc} = Floki.parse_document(res.body)

    %{
      job_global_id: "elixirjobs" <> url,
      job_link:
        Floki.find(doc, ".level-item > .button")
        |> Floki.attribute("href")
        |> hd,
      raw: res.body,
      strings: [
        get_text(doc, ".title > small"),
        get_text(doc, ".body"),
        get_text(doc, ".is-link"),
        get_text(doc, ".is-danger")
      ],
      title: get_text(doc, ".title > strong"),
      description: get_text(doc, ".body")
    }
  end
end
