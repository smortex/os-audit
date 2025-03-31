module OpenSearch
  module Audit
    module Checks
      # Look for dynamic mapping in indices
      class DoubleKeyword < Base
        def check
          @index_list.each do |_group_name, indices|
            indices.each do |index|
              offenses = double_keywords(index.mapping)
              if offenses.any?
                logger.warn "#{offenses.count} fields with double-keyword mapping in #{index.name}"
                offenses.each do |mapping|
                  logger.info "\tField #{mapping} is indexed twice as a keyword"
                end
              end
            end
          end
        end

        def double_keywords(mapping, key: [])
          return [] unless mapping.is_a?(Hash)

          result = []

          if mapping["type"] == "keyword" && mapping.dig("fields", "keyword", "type") == "keyword"
            result << key.join(".")
          else
            mapping.each do |k, v|
              result += double_keywords(v, key: key + [k])
            end
          end

          result
        end
      end
    end
  end
end
