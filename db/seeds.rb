# == Seeds Directory ========================================================= #

filepath = File.join(File.dirname(__FILE__),"seeds")

# == Seed Teams ============================================================== #

if Team.all.empty?
  puts "== seeds.rb Team: seeding ".ljust(79, "=")
  puts "-- create teams (64)"
  t_start = Time.now

  colnames = Team.attribute_names.reject{|colname| colname == "id"}

  File.read(File.join(filepath,"teams.dat")).gsub(/[^\S \r\n]/,"").split("\n").each.with_index(1) do |line, cnt|
    print "\r   -> %d" % cnt
    attributes = line.split(/ {2,}/).map.with_index{|attribute, i| [colnames[i], attribute]}.to_h
    Team.create(attributes)
  end
  puts "\r   -> %.4fs" % (Time.now - t_start)
  puts "== seeds.rb Team: seeded #{"(%.4fs)" % (Time.now - t_start)} ".ljust(79, "=")
  puts
end

# == Seed Users ============================================================== #

if User.all.empty?
  puts "== seeds.rb User: seeding ".ljust(79, "=")
  puts "-- create users (100)"
  t_start = Time.now

  colnames = User.attribute_names.reject{|colname| colname == "id"}
  colnames[colnames.index("password_digest")] = "password"

  alpha_numeric  = [*"a".."z", *"A".."Z", *"0".."9"]
  special_chars  = "!#$%&()*+,-.:;<=>?@[]^_{}".chars
  password_chars = alpha_numeric + special_chars

  names     = File.read(File.join(filepath,    "users.dat")).gsub(/\s/,"  ").split(/ {2,}/)
  usernames = File.read(File.join(filepath,"usernames.dat")).gsub(/\s/,"  ").split(/ {2,}/)
  passwords = usernames.collect{ password_chars.sample([*8..12].sample).join }
  user_info = [usernames, passwords, names].transpose

  file = File.new(File.join(filepath,"out.txt"), "w")
  file.puts "#{"NAME".ljust(11)}#{"USERNAME".ljust(18)}#{"PASSWORD"}"
  user_info.each.with_index(1) do |arr, cnt|
    print "\r   -> %d" % cnt
    attributes = arr.map.with_index{|attribute, i| [colnames[i], attribute]}.to_h
    user = User.new(attributes)
    if !!user.save
      file.puts "#{arr[2].ljust(11)}#{arr[0].ljust(18)}#{arr[1]}"
    end
  end
  file.close
  puts "\r   -> %.4fs" % (Time.now - t_start)
  puts "== seeds.rb User: seeded #{"(%.4fs)" % (Time.now - t_start)} ".ljust(79, "=")
  puts
end

# == Seed Brackets and Games ================================================= #

if Bracket.all.empty?
  puts "== seeds.rb Bracket and Game: seeding ".ljust(79, "=")
  puts "-- create brackets (100) and games (6300)"
  t_start = Time.now

  User.all.each.with_index(1) do |user, cnt|
    print "\r   -> %d" % cnt
    bracket = user.build_bracket(:name => "#{user.username}_0001")
    if !!bracket.save
      until (championship = bracket.games.find_by(:round => "Championship")) && !!championship.winner
        if bracket.games.empty?
          Team.final_four_region_pairings.each do |region_pair|
            region_pair.each do |region_name|
              Bracket.first_round_logic.each do |game_index, game_logic|
                game = bracket.games.build(:round => "1st Round")
                if !!game.save
                  game.teams.push(
                    Team.find_by(:region => region_name, :region_seed => game_logic.values.first.to_i),
                    Team.find_by(:region => region_name, :region_seed => game_logic.values.last.to_i))
                end
              end
            end
          end
        else
          round = bracket.games.last.round
          games = bracket.games.where(:round => round)
          if round == "Championship"
            winner = games.first.teams.sample
            loser  = games.first.teams.reject{|team| team == winner}.first
            Game.update(games.first.id, :team_id_winner => winner.id, :team_id_loser => loser.id)
          else
            next_round = Bracket.rounds[ Bracket.rounds.index(round)+1 ]
            games.each_slice(2) do |parent1, parent2|
              # weight selections based on difference in region_seed
              p1t1, p1t2 = parent1.teams; d1 = (p1t1.region_seed - p1t2.region_seed).abs; n1 = (5+4*d1/15).to_i
              p2t1, p2t2 = parent2.teams; d2 = (p2t1.region_seed - p2t2.region_seed).abs; n2 = (5+4*d2/15).to_i
              p1t1.region_seed < p1t2.region_seed ? raffle1 = [p1t1]*n1 + [p1t2]*(10-n1) : raffle1 = [p1t2]*n1 + [p1t1]*(10-n1)
              p2t1.region_seed < p2t2.region_seed ? raffle2 = [p2t1]*n2 + [p2t2]*(10-n2) : raffle2 = [p2t2]*n2 + [p2t1]*(10-n2)
              winner1 = raffle1.sample; loser1 = parent1.teams.reject{|team| team == winner1}.first
              winner2 = raffle2.sample; loser2 = parent2.teams.reject{|team| team == winner2}.first
              Game.update(parent1.id, :team_id_winner => winner1.id, :team_id_loser => loser1.id)
              Game.update(parent2.id, :team_id_winner => winner2.id, :team_id_loser => loser2.id)
              game = bracket.games.build(:round => next_round)
              game.teams.push(winner1, winner2) if !!game.save
            end
          end
        end
      end
    end
  end
  puts "\r   -> %.4fs" % (Time.now - t_start)
  puts "== seeds.rb Bracket and Game: seeded #{"(%.4fs)" % (Time.now - t_start)} ".ljust(79, "=")
  puts
end
