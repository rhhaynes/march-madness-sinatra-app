require "bundler/setup"
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/database.sqlite"
)

# require_all lib directory
require_all "lib"

# require_all app directory
%w[helpers models views controllers].each do |dir|
  require_all File.join("app", dir)
end
