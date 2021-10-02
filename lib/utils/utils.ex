defmodule Utils do
  @moduledoc false

  def save_jobs(jobs, org) do
    file =
      case File.read("db/jobs.json") do
        {:ok, content} -> content
        _ -> File.write("db/jobs.json", "{}")
      end

    {:ok, old_jobs} = Jason.decode(file)

    current =
      case org in Map.keys(old_jobs) do
        true -> %{old_jobs | org => jobs}
        _ -> Map.merge(old_jobs, %{org => jobs})
      end
      |> Jason.encode!()

    File.write!("db/jobs.json", current)
  end
end
