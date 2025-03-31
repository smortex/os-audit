module OpenSearch
  module Audit
    module Checks
      # Look for dynamic mapping in indices
      class DynamicMapping < Base
        def check
          @index_list.each do |_group_name, indices|
            indices.each do |index|
              if (offenses = dynamic_mappings_count(index.mapping))
                logger.warn "Index #{index.name} seems to have #{offenses} dynamic mappings"
              end
            end
          end
        end

        def dynamic_mappings_count(mapping, key: [])
          return 0 unless mapping.is_a?(Hash)

          result = 0

          if mapping["fields"] == {"keyword" => {"type" => "keyword", "ignore_above" => 256}}
            logger.info "Field #{key.reject { |v| v == "properties" }.join(".")} looks like a dynamic field to me"
            result += 1
          else
            mapping.each do |k, v|
              result += dynamic_mappings_count(v, key: key + [k])
            end
          end

          result
        end
      end
    end
  end
end
