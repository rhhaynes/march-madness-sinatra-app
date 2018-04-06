# seeds directory
filepath = File.join(File.dirname(__FILE__),"seeds")

# seed teams
colnames = Team.attribute_names.reject{|colname| colname == "id"}
File.read(File.join(filepath,"teams.dat")).gsub(/[^\S \r\n]/,"").split("\n").each do |line|
  attributes = line.split(/ {2,}/).map.with_index{|attribute, i| [colnames[i], attribute]}.to_h
  Team.create(attributes)
end
