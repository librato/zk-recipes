#
# Provides a simple way to register a presence
#
module ZkRecipes
  module Presence
    def self.update(namespace, node_id, payload)
      root = "/#{namespace}"

      r = ZkRecipes::conn.create(:path => root)
      if r[:rc] != Zookeeper::ZOK &&
          r[:rc] != Zookeeper::ZNODEEXISTS
        raise "Failed to create namespace: %s" % namespace
      end

      presence_path = "#{root}/#{node_id}"
      r = ZkRecipes::conn.create(:path => presence_path, :data => payload)
      if r[:rc] != Zookeeper::ZOK &&
          r[:rc] != Zookeeper::ZNODEEXISTS
        raise "Failed to create node id: %s" % presence_path
      end

      # Update payload
      r = ZkRecipes::conn.set(:path => presence_path, :data => payload)
      if r[:rc] != Zookeeper::ZOK
        raise "Failed to update presence path: %s" % presence_path
      end
    rescue ZookeeperExceptions::ZookeeperException => err
      raise "Failed to connect to ZK: #{err.message}"
    end
  end
end
