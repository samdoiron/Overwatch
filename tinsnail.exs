stats = Overwatch.get_pc_profile("TinSnail", 1627, :north_america)
for hero <- stats do
  IO.puts(hero.hero_name)
  IO.puts("\tWins: #{hero.win_count}")
  IO.puts("\tTies: #{hero.tie_count}")
  IO.puts("\tLosses: #{hero.loss_count}")
  IO.puts("")
end
