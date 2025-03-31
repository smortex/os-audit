module OpenSearch
  module Audit
    module Checks
      class Base
        attr_reader :options

        def initialize(index_list, options = {})
          @index_list = index_list
          @options = options
        end
      end
    end
  end
end
