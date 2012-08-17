class Entry

  attr_reader :path

  def initialize(options)
    if options[:remote_entry]
      @path = options[:remote_entry].path
      @remote_timestamp = Time.parse(options[:remote_entry].modified).utc
    else
      @path = options[:remote_path]
      @local_timestamp = File.mtime(options[:local_path]).utc unless options[:local_path].nil?
    end
  end

  def remote_newer?
    !exists_locally? || row["remote_updated_at"].nil? || @remote_timestamp.to_i > Time.parse(row["remote_updated_at"]).utc.to_i
  end

  def local_newer?
    !exists_locally? || row["local_updated_at"].nil? || @local_timestamp.to_i > Time.parse(row["local_updated_at"]).utc.to_i
  end

  def update_local(&block)
    MappingDatabase.instance.db.transaction do
      @local_timestamp = block.call.utc

      update_db
    end
  end

  def update_remote(&block)
    MappingDatabase.instance.db.transaction do
      @remote_timestamp = Time.parse(block.call).utc

      update_db
    end
  end

  def update_db    
    remote_timestamp = convert_time(@remote_timestamp)
    local_timestamp = convert_time(@local_timestamp)

    if exists_locally?
      MappingDatabase.instance.db.execute("UPDATE mappings SET remote_updated_at = ?, local_updated_at = ? WHERE path = ?", remote_timestamp, local_timestamp, @path)
    else
      MappingDatabase.instance.db.execute("INSERT INTO mappings (path, remote_updated_at, local_updated_at) VALUES(?,?,?)", @path, remote_timestamp, local_timestamp)
    end
  end

  def delete(&block)
    MappingDatabase.instance.db.transaction do
      yield
      MappingDatabase.instance.db.execute("DELETE FROM mappings WHERE path = ?", @path)
    end
  end

  def row
    @row ||= MappingDatabase.instance.db.get_first_row( "SELECT * FROM mappings WHERE path = ?", @path )
  end

  def exists_locally?
    !row.nil?
  end

  def reload
    @row = nil
    row
  end

  def self.all
    MappingDatabase.instance.db.execute("SELECT * FROM mappings").map do |e|
      Entry.new :remote_path => e["path"]
    end
  end

  private

  def convert_time(time)
    time.strftime("%Y-%m-%d %H:%M:%S")
  end
end
