defmodule Github do
  @moduledoc false

  @url "https://api.github.com/"

  defp count_issues(org, repo) do
    {:ok, response} = HTTPoison.get(@url <> "repos/#{org}/#{repo}")
    {:ok, data} = Jason.decode(response.body)

    trunc(data["open_issues"] / 100)
  end

  def get_issues(org, repo) do
    case count_issues(org, repo) do
      {:ok, value} -> Enum.map(1..value, fn page -> get_issue(org, repo, page) end)
      _ -> []
    end
  end

  defp get_issue(org, repo, page) do
    {:ok, response} =
      HTTPoison.get(@url <> "repos/#{org}/#{repo}/issues?state=open&page=#{page}&per_page=100")

    {:ok, data} = Jason.decode(response.body)

    Enum.map(data, fn issue ->
      vacancy =
        Map.drop(issue, [
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
          # Talvez eu remova isso
          "users"
        ])

      %{
        vacancy
        | "labels" =>
            Enum.map(
              vacancy["labels"],
              &Map.drop(&1, ["color", "default", "id", "url", "node_id"])
            )
      }
    end)
  end
end
