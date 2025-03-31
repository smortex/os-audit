module OpenSearch
  module Audit
    module Checks
      # Look for dynamic mapping in indices
      class DynamicMapping < Base
        def check
          @index_list.each do |_group_name, indices|
            indices.each do |index|
              if dynamic_mapping?(index.mapping)
                warn "Index #{index.name} seems to have dynamic mapping"
              end
            end
          end
        end

        def dynamic_mapping?(mapping, key: [])
          return false unless mapping.is_a?(Hash)

          result = false

          if mapping["type"] == "keyword" && mapping["ignore_above"] == 256
            warn "Field #{key.join(".")} looks like a dynamic field to me"
            result = true
          else
            mapping.each do |k, v|
              result = true if dynamic_mapping?(v, key: key + [k])
            end
          end

          result
        end
      end
    end
  end
end
