#
# Provides a simple service to ensure only one participating member
# proceeds. This is a simple, one-time, leader election without
# persistent heartbeating.
#
module ZkRecipes
  module Exclusive
    #
    # Should the invoking process proceed as the leader of the given
    # namespace. Performs a simple-leader election check in the
    # namespace.
    #
    # It is assumed that the process will exit -- destroying its
    # znode -- to release its position as leader.
    #
    # TODO: add an explicit release
    #
    def self.proceed?(namespace)
      root = "/#{namespace}"

      r = ZkRecipes::conn.create(:path => root)
      if r[:rc] != Zookeeper::ZOK &&
          r[:rc] != Zookeeper::ZNODEEXISTS
        raise "Failed to create namespace: %s" % namespace
      end

      electpath = "#{root}/n_"

      r = ZkRecipes::conn.create(:path => electpath,
                                 :ephemeral => true,
                                 :sequence => true)
      if r[:rc] != Zookeeper::ZOK
        raise "Failed to create election path: %s" % electpath
      end

      # Determine the base pathname we created
      base = File.basename(r[:path])

      # Read the set of nodes created in our namespace
      r = ZkRecipes::conn.get_children(:path => root)
      if r[:rc] != Zookeeper::ZOK
        raise "Failed to lookup namespace children: %s" % namespace
      end

      # We are the leader if we created the first znode
      base == r[:children].sort.first
    rescue ZookeeperExceptions::ZookeeperException => err
      raise "Failed to connect to ZK: #{err.message}"
    end
  end
end
