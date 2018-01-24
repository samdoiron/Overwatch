defmodule Overwatch.Profile do
  defmodule HeroStats do
    defstruct hero_name: "", win_count: 0, tie_count: 0, loss_count: 0
  end

  defstruct name: "", hero_stats: %{}
end
