module OpenSearch
  module Audit
    class IndexList
      module Periodicity
        def yearly?
          @indices.all?(&:yearly?)
        end

        def monthly?
          @indices.all?(&:monthly?)
        end

        def daily?
          @indices.all?(&:daily?)
        end

        def hourly?
          @indices.all?(&:hourly?)
        end
      end
    end
  end
end
