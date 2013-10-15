# encoding: utf-8
#
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

require 'rails/generators/named_base'
require 'rails/generators/active_model'

module Couchbase #:nodoc:
  module Generators #:nodoc:

    class Base < ::Rails::Generators::NamedBase #:nodoc:

      def self.source_root
        @_couchbase_source_root ||=
          File.expand_path("../#{base_name}/#{generator_name}/templates", __FILE__)
      end

      unless methods.include?(:module_namespacing)
        def module_namespacing(&block)
          yield if block
        end
      end

    end

  end
end
