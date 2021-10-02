defmodule RemoteOk do
  @moduledoc false
  @url "https://remoteok.io/"

  def get_epoch() do
    {:ok, res} = HTTPoison.get(@url)
    %{"epoch" => epoch} = Regex.named_captures(~r/data-epoch="(?<epoch>[0-9]+)"/, res.body)
    %{epoch: String.to_integer(epoch), body: res.body}
  end

  def get_epoch(current_epoch) do
    {:ok, res} = HTTPoison.get(@url <> "/?pagination=#{current_epoch}&worldwide=false")
    %{"epoch" => epoch} = Regex.named_captures(~r/data-epoch="(?<epoch>[0-9]+)"/, res.body)
    %{epoch: String.to_integer(epoch), body: res.body}
  end

  def get_job(html) do
    {:ok, document} = Floki.parse_document(html)

    document
    |> Floki.find(".company .position .company_and_position")
    |> Floki.text()
  end
end
