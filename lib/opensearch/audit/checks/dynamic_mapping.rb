OpenSearch::Audit.add_check(:dynamic_mapping) do
  def check
    dynamic_fields = []
    @index_list.each do |index|
      offenses = dynamic_mappings(index.mapping)
      if offenses.any?
        logger.warn "#{offenses.count} dynamic mappings detected in index #{index.name}"
        offenses.each do |mapping|
          logger.info "\tField #{mapping} looks like a dynamic field to me"
        end
        dynamic_fields += offenses
      end
    end

    return unless options[:template_filename] && @index_list.index_pattern

    dynamic_fields.uniq!

    dynamic_fields.each do |mapping|
      current_field_mapping = options[:template].dig("template", *mapping.split("."))

      next unless current_field_mapping.nil? || current_field_mapping == OpenSearch::Audit::Index::DEFAULT_MAPPING

      field = mapping_field_name(mapping)

      query = {
        size: 0,
        aggs: {
          result: {
            terms: {
              field: "#{field}.keyword",
              size: 10
            }
          }
        }
      }

      res = @index_list.client.search(index: @index_list.index_pattern, body: query)

      type = detect_field_type(res)

      o = options[:template]["template"]
      mapping.split(".").each do |piece|
        o = o[piece] ||= {}
      end

      o["type"] = type
    end
  end

  def dynamic_mappings(mapping, key: [])
    return [] unless mapping.is_a?(Hash)

    result = []

    if mapping == OpenSearch::Audit::Index::DEFAULT_MAPPING
      result << key.join(".")
    else
      mapping.each do |k, v|
        result += dynamic_mappings(v, key: key + [k])
      end
    end

    result
  end

  def mapping_field_name(mapping)
    components = mapping.split(".")
    components.shift
    components.select!.with_index { |_, index| index.odd? }.join(".")
  end

  def detect_field_type(res)
    other_doc_count = res.dig("aggregations", "result", "sum_other_doc_count")
    top_values = res.dig("aggregations", "result", "buckets").map { |bucket| bucket["key"] }

    if top_values.empty?
      # If there is no top value, field values are longer than the default limit.
      # Probably not UIDS or things that should be indexed full.
      "text"
    elsif top_values.all? { |value| ["true", "false"].include?(value) }
      "boolean"
    elsif (range = int_range(top_values))
      if (-128..127).cover?(range)
        "byte"
      elsif (-2**15..2**15 - 1).cover?(range)
        "short"
      elsif (-2**31..2**31 - 1).cover?(range)
        "integer"
      elsif (-2**63..2**63 - 1).cover?(range)
        "long"
      elsif (0..2**64 - 1).cover?(range)
        "unsigned_long"
      else
        "wot"
      end
    elsif float_range(top_values)
      "float"
    elsif other_doc_count.zero?
      # We have a complete set, so likely not something that hold a lot of different values
      "keyword"
    elsif top_values.all? { |value| value.match?(/\A{?[[:xdigit:]]+}?\z/) } && top_values.map(&:size).uniq.size == 1
      # Some kind of UID
      "keyword"
    elsif top_values.all? { |value| value.match?(/[[:blank:]]/) }
      "text"
    else
      "keyword"
    end
  end

  def int_range(values)
    ints = values.map do |value|
      Integer(value, 10)
    end
    ints.min..ints.max
  rescue ArgumentError
    nil
  end

  def float_range(values)
    floats = values.map do |value|
      Float(value)
    end
    floats.min..floats.max
  rescue ArgumentError
    false
  end
end
