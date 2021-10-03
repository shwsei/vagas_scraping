defmodule JobsScraping.VueJobs do
  @moduledoc false

  @url "https://vuejobs.com/"

  def get_jobs() do
    {:ok, res} = HTTPoison.get(@url <> "api/positions/search/?jobs_per_page=1000&page=1")
    {:ok, json} = Jason.decode(res.body)

    json["data"]
    |> Enum.map(fn job ->
      %{
        raw: Jason.encode!(job),
        job_global_id: "vuejobs:rest/" <> job["key"],
        desccription: job["description"],
        strings: [
          job["description"],
          job["category"],
          job["location"],
          job["company"]
        ],
        title: job["title"],
        job_link: job["apply_link"],
        job_updated_at: job["published_at"]
      }
    end)
  end
end
