OpenSearch::Audit.add_check(:unexpected_type) do
  def check
    @index_list.each do |index|
      offenses = unexpected_types(index.mapping)
      if offenses.any?
        logger.warn "#{offenses.count} fields with unexpected types in #{index.name}"
        offenses.each do |offense|
          logger.info "\t#{offense}"
        end
      end
    end
  end

  def unexpected_types(mapping, key: [])
    return [] unless mapping.is_a?(Hash)

    result = []

    if mapping.has_key?("type")
      expected_types = case key.last
      when "address" then ["ip", "keyword", "wildcard"]
      when "ip", /_ip$/ then ["ip"]
      when "port", /_port$/ then ["integer"]
      when "uid", "gid" then ["integer"]
      end

      if expected_types && !expected_types.include?(mapping["type"])
        result << OpenSearch::Audit::Checks::UnexpectedType::Offense.new(key.join("."), mapping["type"], expected_types)
      end
    else
      mapping.each do |k, v|
        result += unexpected_types(v, key: key + [k])
      end
    end

    result
  end
end

class OpenSearch::Audit::Checks::UnexpectedType::Offense
  attr_reader :field, :actual

  def initialize(field, actual, expected)
    @field = field
    @actual = actual
    @expected = expected
  end

  def expected
    if @expected.count > 1
      "one of #{@expected.join(", ")}"
    else
      @expected.first
    end
  end

  def to_s
    "Field #{field} is of type #{actual} but should be #{expected}"
  end
end
