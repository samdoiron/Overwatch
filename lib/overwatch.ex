defmodule Overwatch do
  alias Overwatch.ProfileFetcher
  alias Overwatch.ProfileParser

  @moduledoc """
  A client for the Overwatch data, scraped from public
  profile pages.
  """

  def get_pc_profile(name, id, region) do
    ProfileFetcher.fetch_pc_profile(name, id, region)
    |> ProfileParser.parse_profile()
  end
end
