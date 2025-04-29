module OpenSearch
  module Audit
    class IndexList
      module Array
        def count
          @indices.count
        end

        def first
          @indices.first
        end

        def last
          @indices.last
        end

        def each(&block)
          @indices.each(&block)
        end

        def map(&block)
          @indices.map(&block)
        end

        def where(filters)
          self.class.new(client: client, options: options, indices: @indices.select do |index|
            filters.all? do |k, v|
              index.send(k) == v
            end
          end)
        end

        def find_by(filters)
          where(filters).first
        end
      end
    end
  end
end
