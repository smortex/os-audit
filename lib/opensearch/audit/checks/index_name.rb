module OpenSearch
  module Audit
    module Checks
      class IndexName < Base
        def check
          @index_list.each do |group_name, indices|
            indices.each do |index|
              if index.name =~ /\d{4}-\d{2}-\d{2}/
                logger.warn("Prefer YYYY.MM.dd to YYYY-MM-dd for naming indices: #{index.name}")
              end
            end
          end
        end
      end
    end
  end
end
