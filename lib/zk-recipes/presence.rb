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

    def self.list(namespace)
      root = "/#{namespace}"

      # Read the set of nodes created in our namespace
      r = ZkRecipes::conn.get_children(:path => root)
      if r[:rc] != Zookeeper::ZOK
        raise "Failed to lookup namespace children: %s" % namespace
      end

      clients = []
      kids = r[:children]

      kids.each do |kid|
        path = "#{root}/#{kid}"

        r = ZkRecipes::conn.get(:path => path)
        if r[:rc] != Zookeeper::ZOK
          raise "Failed to lookup server details for: %s (disappeared?)" %
            namespace
        end

        clients << r[:data]
      end

      clients
    rescue ZookeeperExceptions::ZookeeperException => err
      raise "Failed to connect to ZK: #{err.message}"
    end
  end
end
