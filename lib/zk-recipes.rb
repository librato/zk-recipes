
require 'zookeeper'

$:.unshift File.join(File.dirname(__FILE__), 'zk-recipes')

require 'exclusive'

module ZkRecipes
  def self.version
    File.read(File.join(File.dirname(__FILE__), '../VERSION')).chomp
  end

  def self.setup(host, port = 2181)
    @@conn = Zookeeper.new("%s:%d" % [host, port])
    unless @@conn
      raise "Unable to connect to ZooKeeper server: %s:%d" % [host, port]
    end
  end

  def self.conn
    @@conn
  end
end
