defmodule Utils do
  def save_vacancies(data, org) do
    file =
      case File.read("db/vacancies.json") do
        {:ok, content} -> content
        _ -> File.write("db/vacancies.json", "{}")
      end

    {:ok, old_vacancies} = Jason.decode(file)

    current =
      case org in Map.keys(old_vacancies) do
        true -> %{old_vacancies | org => data}
        _ -> Map.merge(old_vacancies, %{org => data})
      end
      |> Jason.encode!()

    File.write!("db/vacancies.json", current)
  end
end
