defmodule Webscraping do
  @moduledoc false

  def main do
    [
      %{org: "rustdevbr", repo: "vagas"},
      %{org: "Gommunity", repo: "vagas"},
      %{org: "phpdevbr", repo: "vagas"},
      %{org: "dotnetdevbr", repo: "vagas"},
      %{org: "frontendbr", repo: "vagas"},
      %{org: "react-brasil", repo: "vagas"},
      %{org: "backend-br", repo: "vagas"},
      %{org: "androiddevbr", repo: "vagas"},
      %{org: "CocoaHeadsBrasil", repo: "vagas"},
      %{org: "flutterbr", repo: "vagas"},
      %{org: "qa-brasil", repo: "vagas"},
      %{org: "remotejobsbr", repo: "design-ux-vagas"},
      %{org: "CangaceirosDevels", repo: "vagas_de_emprego"},
      %{org: "frontend-ao", repo: "vagas"},
      %{org: "backend-ao", repo: "vagas"},
      %{org: "frontend-pt", repo: "vagas"},
      %{org: "backend-pt", repo: "vagas"}
    ]
    |> Enum.each(
      fn (%{org: org, repo: repo}) ->
        Github.get_issues(org, repo)
        |> Utils.save_jobs(org)
        IO.puts("Complete: #{org}/#{repo}")
    end)

    PluoJobs.get_jobs()
    |> Utils.save_jobs("pluo_jobs")
    VueJobs.get_jobs()
    |> Utils.save_jobs("vue_jobs")

    ElixirJobs.get_jobs()
  end
end
