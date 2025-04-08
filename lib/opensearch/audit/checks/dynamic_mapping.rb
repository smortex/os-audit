OpenSearch::Audit.add_check(:dynamic_mapping) do
  def check
    @index_list.each do |index|
      offenses = dynamic_mappings(index.mapping)
      if offenses.any?
        logger.warn "#{offenses.count} dynamic mappings detected in index #{index.name}"
        offenses.each do |mapping|
          logger.info "\tField #{mapping} looks like a dynamic field to me"
        end
      end
    end
  end

  def dynamic_mappings(mapping, key: [])
    return [] unless mapping.is_a?(Hash)

    result = []

    if mapping["fields"] == {"keyword" => {"type" => "keyword", "ignore_above" => 256}}
      result << key.join(".")
    else
      mapping.each do |k, v|
        result += dynamic_mappings(v, key: key + [k])
      end
    end

    result
  end
end
