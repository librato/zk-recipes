
module ZkRecipes
  module WorkPool
    #
    # Advertise as a server. Assumes the connection details
    # are in 'conn_info'.
    #
    # Returns: true => we are server
    #          false => we are not the server
    #
    def self.advertise_as_server(namespace, conn_info)
      data = conn_info.to_json

      root = "/#{namespace}"

      r = ZkRecipes::conn.create(:path => root)
      if r[:rc] != Zookeeper::ZOK &&
          r[:rc] != Zookeeper::ZNODEEXISTS
        raise "Failed to create namespace: %s" % namespace
      end

      electpath = "#{root}/n_"

      r = ZkRecipes::conn.create(:path => electpath,
                                 :ephemeral => true,
                                 :sequence => true,
                                 :data => data)
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

      first = r[:children].sort.first

      # We are the leader if we created the first znode
      return [true, nil] if base == first

      # Else, get the details for the server
      path = "#{root}/#{first}"
      r = ZkRecipes::conn.get(:path => path)
      if r[:rc] != Zookeeper::ZOK
        raise "Failed to lookup server details for: %s (disappeared?)" %
          namespace
      end

      data = JSON.parse(r[:data])
      [false, data]
    rescue ZookeeperExceptions::ZookeeperException => err
      raise "Failed to connect to ZK: #{err.message}"
    end
  end
end
