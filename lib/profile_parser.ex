defmodule Overwatch.ProfileParser do
  alias Overwatch.Profile.HeroStats
  alias Overwatch.TreeSearch

  def parse_profile(profile) do
    competitive = find_competitive(Floki.parse(profile))
    heroes = time("Find heroes", fn -> find_heroes_with_option_ids(competitive) end)
    Enum.map(heroes, fn {name, id} ->
      %{ find_hero_stats(competitive, id) | hero_name: name }
    end)
  end

  defp find_heroes_with_option_ids(competitive) do
    competitive
    |> Floki.find("[data-group-id=\"stats\"] option")
    |> Enum.map(fn el -> {Floki.text(el), List.first(Floki.attribute(el, "value"))} end)
    |> Enum.filter(fn {name, _} -> name != "ALL HEROES" end)
  end

  defp find_competitive(page) do
    page
    |> Enum.at(1)
    |> TreeSearch.find_child("itemscope", "itemscope")
    |> TreeSearch.find_child("class", "bg-color-blue-dark")
    |> TreeSearch.find_child("class", "profile-background")
    |> TreeSearch.find_child("id", "competitive")
  end

  defp find_hero_stats(competitive, option_id) do
    stat_blocks = competitive
    |> TreeSearch.find_child("class", "career-stats-section")
    |> TreeSearch.find_child("class", "row")
    |> TreeSearch.find_child("data-category-id", option_id)
    |> Floki.find(".card-stat-block")

    game_block = find_stat_block(stat_blocks, "Game")
    table_data = Floki.find(game_block, "td")

    # why bliz ಠ_ಠ
    {win_count, tie_count, loss_count} = cond do
      # |time, total, wins, losses, percent| * 2
      length(table_data) == 10 ->
        {win_count, ""} = Integer.parse(Floki.text(Enum.at(table_data, 5)))
        {loss_count, ""} = Integer.parse(Floki.text(Enum.at(table_data, 7)))
        {win_count, 0, loss_count}

      # |time, total, wins, ties, losses, percent| * 2
      length(table_data) == 12 ->
        {win_count, ""} = Integer.parse(Floki.text(Enum.at(table_data, 5)))
        {tie_count, ""} = Integer.parse(Floki.text(Enum.at(table_data, 7)))
        {loss_count, ""} = Integer.parse(Floki.text(Enum.at(table_data, 9)))
        {win_count, tie_count, loss_count}

      :else ->
        {0, 0, 0}
    end


    {win_count, tie_count, loss_count} = if length(table_data) < 10 do
      {0, 0, 0}
    else
      {win_count, tie_count, loss_count}
    end


    %HeroStats{
      win_count: win_count,
      tie_count: tie_count,
      loss_count: loss_count
    }
  end

  defp find_stat_block(blocks, name) do
    Enum.find(blocks, &(stat_block_name(&1) == name))
  end

  defp stat_block_name(block) do
    block
    |> Floki.find(".stat-title")
    |> Floki.text()
  end

  defp time(name, block) do
    start = Time.utc_now()
    result = block.()
    IO.puts("#{name} took #{Time.diff(Time.utc_now(), start, :millisecond)}ms")
    result
  end
end
