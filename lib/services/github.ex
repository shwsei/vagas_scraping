defmodule Github do
  def get_issues(org, repo) do
    {:ok, response} =
      HTTPoison.get('https://api.github.com/repos/#{org}/#{repo}/issues?state=open&per_page=100')

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
