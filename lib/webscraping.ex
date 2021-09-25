defmodule Webscraping do
  def main do
    org = "rustdevbr"
    repo = "vagas"

    Github.get_issues(org, repo)
    |> Utils.save_vacancies(org)
  end
end
