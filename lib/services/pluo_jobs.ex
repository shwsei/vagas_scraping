defmodule PluoJobs do
  @moduledoc false

  @url "https://pyjobs.com.br/api/v2/jobs/"

  defp get_values(job) do
    skills =
      Enum.uniq(job["skills"])
      |> get_skills

    %{
      raw: Jason.encode!(job),
      job_global_id: "pyjobs:rest/" <> job["unique_slug"],
      desccription: job["description"],
      strings: [
        job["company_name"],
        job["category"],
        job["location"],
        job["workplace"],
        skills
      ],
      title: job["title"],
      job_link: @url <> job["unique_slug"],
      job_updated_at: job["created_at"]
    }
  end

  defp get_skills(skills) do
    skills
    |> Enum.reduce(
      "",
      fn %{"unique_slug" => unique_slug}, acc ->
        "#{acc} #{unique_slug}"
      end
    )
  end

  def get_jobs(limit \\ 1119) do
    {:ok, res} = HTTPoison.get(@url <> "?format=json&#{limit}=12&page=2")
    {:ok, json} = Jason.decode(res.body)

    json["results"]
    |> Enum.map(&get_values/1)
  end
end
