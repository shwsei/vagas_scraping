defmodule JobsScraping.Github do
  @moduledoc false

  @url "https://api.github.com/"

  defp count_issues(org, repo) do
    {:ok, response} = HTTPoison.get(@url <> "repos/#{org}/#{repo}")
    {:ok, data} = Jason.decode(response.body)
    trunc(data["open_issues"] / 100)
  end

  def get_issues(org, repo) do
    value = count_issues(org, repo)

    Enum.map(1..value, &get_issue(org, repo, &1))
    |> Enum.reduce(&(&1 ++ &2))
  end

  defp get_issue(org, repo, page) do
    {:ok, response} =
      HTTPoison.get(@url <> "repos/#{org}/#{repo}/issues?state=open&page=#{page}&per_page=100")

    {:ok, data} = Jason.decode(response.body)

    Enum.map(data, fn job ->
      raw =
        Map.drop(job, [
          "active_lock_reason",
          "closed_at",
          "comments",
          "labels_url",
          "events_url",
          "author_association",
          "assignees",
          "assigne",
          "node_id",
          "locked",
          "milestone",
          "number",
          "performed_via_github_app",
          "repository_url",
          "user"
        ])

      %{
        raw: Jason.encode!(raw),
        job_global_id: "github/#{org}/#{repo}/#{job["number"]}",
        job_update_id: job["updated_at"],
        title: job["title"],
        description: job["body"],
        strings:
          Enum.map(
            job["labels"],
            fn value ->
              "#{value["name"]} #{value["description"]}"
            end
          ) ++ [ job["body"] ]
      }
    end)
  end
end
