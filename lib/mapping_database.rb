class MappingDatabase
  include Singleton

  attr_reader :db
  DB_PATH = File.dirname(__FILE__) + "/../mappings.db"

  def initialize
    @db = SQLite3::Database.new DB_PATH
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
