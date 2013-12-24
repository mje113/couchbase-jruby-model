# Author:: Couchbase <info@couchbase.com>
# Copyright:: 2012 Couchbase, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'minitest/autorun'
require 'couchbase'
require 'couchbase/model'

require 'socket'
require 'open-uri'
require 'pry'

class CouchbaseServer
  attr_accessor :host, :port, :num_nodes, :buckets_spec

  def real?
    true
  end

  def initialize(params = {})
    @host, @port = ENV['COUCHBASE_SERVER'].split(':')
    @port = @port.to_i

    if @host.nil? || @host.empty? || @port == 0
      raise ArgumentError, 'Check COUCHBASE_SERVER variable. It should be hostname:port'
    end

    @config = MultiJson.load(open("http://#{@host}:#{@port}/pools/default"))
    @num_nodes = @config['nodes'].size
    @buckets_spec = params[:buckets_spec] || 'default:'  # "default:,protected:secret,cache::memcache"
  end

  def start
    # flush all buckets
    @buckets_spec.split(',') do |bucket|
      name, password, _ = bucket.split(':')
      connection = Couchbase.new(:hostname => @host,
                                 :port => @port,
                                 :username => name,
                                 :bucket => name,
                                 :password => password)
      connection.flush
    end
  end
  def stop; end
end

require 'java'
require "#{File.dirname(__FILE__)}/CouchbaseMock.jar"

class CouchbaseMock

  Monitor = Struct.new(:pid, :client, :socket, :port)

  attr_accessor :host, :port, :buckets_spec, :num_nodes, :num_vbuckets

  def real?
    false
  end

  def initialize(params = {})
    @host = 'localhost'
    @port = 8091
    @num_nodes = 1
    @num_vbuckets = 4096
    @buckets_spec = 'default:'  # "default:,protected:secret,cache::memcache"
    params.each do |key, value|
      send("#{key}=", value)
    end
    yield self if block_given?
    if @num_vbuckets < 1 || (@num_vbuckets & (@num_vbuckets - 1) != 0)
      raise ArgumentError, 'Number of vbuckets should be a power of two and greater than zero'
    end
  end

  def start
    @mock = Java::OrgCouchbaseMock::CouchbaseMock.new(@host, @port, @num_nodes, @num_vbuckets, @buckets_spec)
    @mock.start
    @mock.waitForStartup
  end

  def stop
    @mock.stop
  end

  def failover_node(index, bucket = 'default')
    @monitor.client.send("failover,#{index},#{bucket}", 0)
  end

  def respawn_node(index, bucket = 'default')
    @monitor.client.send("respawn,#{index},#{bucket}", 0)
  end
end

class MiniTest::Unit::TestCase

  def start_mock(params = {})
    mock = nil
    if ENV['COUCHBASE_SERVER']
      mock = CouchbaseServer.new(params)
      if (params[:port] && mock.port != params[:port]) ||
        (params[:host] && mock.host != params[:host]) ||
        mock.buckets_spec != 'default:'
        skip("Unable to configure real cluster. Requested config is: #{params.inspect}")
      end
    else
      mock = CouchbaseMock.new(params)
    end
    mock.start
    mock
  end

  def stop_mock(mock)
    assert(mock)
    mock.stop
  end

  def with_mock(params = {})
    mock = nil
    if block_given?
      mock = start_mock(params)
      yield mock
    end
  ensure
    stop_mock(mock) if mock
  end

  def uniq_id(*suffixes)
    test_id = [caller.first[/.*[` ](.*)'/, 1], suffixes].compact.join('_')
    @ids ||= {}
    @ids[test_id] ||= Time.now.to_f
    [test_id, @ids[test_id]].join('_')
  end
end
