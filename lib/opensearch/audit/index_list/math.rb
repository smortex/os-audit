module OpenSearch
  module Audit
    class IndexList
      module Math
        def median(values)
          if values.count.even?
            pos = values.count / 2
            values.sort[(pos - 1)..pos].sum / 2
          else
            values.sort.at(values.count / 2)
          end
        end

        def median_trend(values, n)
          sample = values.last(n)
          median(sample)
        end
      end
    end
  end
end
