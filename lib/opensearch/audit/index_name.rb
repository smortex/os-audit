module OpenSearch
  module Audit
    class IndexName
      attr_reader :name

      def initialize(index)
        @name = index["index"]
      end

      def base_name
        name.gsub(/\d{4}\.\d{2}\.\d{2}$/, "YYYY.MM.dd")
          .gsub(/\d{4}\.\d{2}$/, "YYYY.MM")
          .gsub(/\d{4}$/, "YYYY")
      end

      def periodic?
        base_name != name
      end
    end
  end
end
