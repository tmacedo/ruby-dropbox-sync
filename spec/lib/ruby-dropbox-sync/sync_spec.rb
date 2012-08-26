# encoding: utf-8
require "spec_helper"

describe Sync do

  before do
    Sync.sync!
  end

  it "should create a directory" do
    file_name = "test-dir-" + SecureRandom.hex(16)
    Dir.mkdir(Configuration.values[:sync_dir] + "/" + file_name)
    Sync.sync!

    Entry.new(:remote_path => file_name).exists_locally?.should be_true
  end

  it "should create a file" do
    file_name = "test-file-" + SecureRandom.hex(16)
    File.open(Configuration.values[:sync_dir] + "/" + file_name, 'w') { |f| f.write("a") }
    Sync.sync!

    Entry.new(:remote_path => file_name).exists_locally?.should be_true
  end

  it "should delete a directory" do
    file_name = "test-dir-" + SecureRandom.hex(16)
    local_name = Configuration.values[:sync_dir] + "/" + file_name
    Dir.mkdir(local_name)
    Sync.sync!

    Entry.new(:remote_path => file_name).exists_locally?.should be_true
    
    Dir.rmdir(local_name)
    Sync.sync!

    Entry.new(:remote_path => file_name).exists_locally?.should be_false
  end
 
  it "should delete a file" do
    file_name = "test-file-" + SecureRandom.hex(16)
    local_name = Configuration.values[:sync_dir] + "/" + file_name
    File.open(local_name, 'w') { |f| f.write("a") }
    Sync.sync!

    Entry.new(:remote_path => file_name).exists_locally?.should be_true

    File.delete local_name
    Sync.sync!
 
    Entry.new(:remote_path => file_name).exists_locally?.should be_false
  end

  it "should delete a file if parent directory is deleted" do
    dir_name = "test-dir-" + SecureRandom.hex(16)
    local_dir_name = Configuration.values[:sync_dir] + "/" + dir_name
    Dir.mkdir(local_dir_name)

    file_name = File.join(dir_name, "test-file-" + SecureRandom.hex(16))
    local_name = File.join(Configuration.values[:sync_dir], file_name)
    File.open(local_name, 'w') { |f| f.write("a") }
    Sync.sync!

    Entry.new(:remote_path => dir_name).exists_locally?.should be_true
    Entry.new(:remote_path => file_name).exists_locally?.should be_true

    FileUtils.rm_rf local_dir_name
    Sync.sync!
 
    Entry.new(:remote_path => dir_name).exists_locally?.should be_false
    Entry.new(:remote_path => file_name).exists_locally?.should be_false
  end
end
