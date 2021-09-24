defmodule Webscraping do
  def main(_args) do
    org = "frontendbr"
    repo = "vagas"
    IO.puts(repo)

    Github.get_issues(org, repo)
    |> Utils.save_vacancies(org)
  end
end
