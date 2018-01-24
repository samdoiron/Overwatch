defmodule Overwatch.ProfileFetcher do
  @region_url_parts %{
    :north_america => "en-us"
  }

  def fetch_pc_profile(name, id, region \\ :north_america) do
    HTTPoison.get!(url_for(region, "pc", "#{name}-#{id}"))
    |> Map.get(:body)
  end

  defp url_for(region, platform, name) do
    "https://playoverwatch.com/#{@region_url_parts[region]}/career/#{platform}/#{name}"
  end
end
