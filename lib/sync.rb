module Sync

  EXCLUDED_LOCAL_PATHS=[".", ".."]
  @@client = Dropbox::API::Client.new(:token  => Configuration.values[:access_token], :secret => Configuration.values[:access_secret])
  @@dir = Configuration.values[:sync_dir]

  def self.fetch_from_remote
    
    files_found = []
    folders_to_search = [""]

    while folder = folders_to_search.pop
      @@client.ls(folder).each do |entry|
        files_found << entry.path
        local_path = File.join(@@dir, entry.path)
        e = Entry.new :remote_entry => entry, :local_path => local_path

        if entry.is_a? Dropbox::API::Dir
          folders_to_search << entry.path
        end

        if e.remote_newer?
          e.update_local do
            if entry.is_a? Dropbox::API::Dir
	      begin
                Dir.mkdir local_path
              rescue Errno::EEXIST => e # if it's a directory and already exists, let's ignore
	        raise e unless File.directory? local_path
	      end
            else
              File.open(local_path, "w") {|f| f.write(@@client.download(entry.path)) }
            end

            File.mtime local_path
          end
        end
      end
    end

    files_found
  end

  def self.delete_from_local(files_found)
    Entry.all.each do |e|
      unless files_found.include? e.path
        e.delete do
          FileUtils.rm_rf File.join(@@dir, e.path)
        end
      end
    end
  end

  def self.push_from_local
    files_found = []
    folders_to_search = [@@dir]
    while folder = folders_to_search.pop
      Dir.foreach(folder) do |f|
        next if EXCLUDED_LOCAL_PATHS.include? f

        local_path = File.join(folder,f)
        remote_path = local_path[@@dir.size + 1..local_path.size]
        files_found << remote_path

        e = Entry.new :remote_path => remote_path, :local_path => local_path

        if File.directory? local_path
          folders_to_search << local_path
        end

        if e.local_newer?
          e.update_remote do
            if File.directory? local_path
              begin
                @@client.mkdir remote_path
              rescue Dropbox::API::Error::Forbidden => e
                # this is a fake change, due to improper handling of directory mtime changes caused by subdirectories or files
                raise e unless e.message.include? "already exists."
              end
	      @@client.search(File.basename(remote_path), :path => File.dirname(remote_path)).first.modified
            else
              @@client.upload(remote_path, open(local_path).read)
              @@client.find(remote_path).modified
            end
          end
        end
      end
    end
    files_found
  end

  def self.delete_from_remote(files_found)
    Entry.all.each do |e|
      unless files_found.include? e.path
        e.delete do
          begin
            @@client.raw.delete :path => e.path
          rescue Dropbox::API::Error::NotFound # it was already deleted
          end
        end
      end
    end
  end
end

