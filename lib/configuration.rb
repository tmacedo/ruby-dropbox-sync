class Configuration

  PATH = "config.yml"

  def initialize
  end

  def self.values
    @@config ||= YAML.load_file(PATH)
  rescue
    {}
  end

  def self.write(key, obj)
    self.values
    @@config[key] = obj

    File.open(PATH, "w") do |f|
      f.write(@@config.to_yaml)
    end
  end
end
