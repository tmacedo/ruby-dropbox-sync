class MappingDatabase
  include Singleton

  attr_reader :db

  def initialize
    @db = SQLite3::Database.new "mappings.db"
    @db.results_as_hash = true
    create unless setup?
  end

  def db
    @db
  end

  def setup?
    !db.get_first_row("SELECT name FROM sqlite_master WHERE type='table' AND name='mappings';").nil?
  end

  def create
    db.execute "CREATE TABLE mappings (path TEXT PRIMARY KEY, remote_updated_at DATETIME, local_updated_at DATETIME);"
  end
end
