module OpenSearch
  module Audit
    class Index
      attr_reader :name, :shard_size, :primary_size, :pri

      def initialize(index)
        @name = index["index"]
        @pri = index["pri"].to_i
        @primary_size = index["pri.store.size"].to_i

        # We assume size is spread evenly across all primary shards
        @shard_size = primary_size / pri

        @user_data = {}
      end

      def enrich(type, user_data)
        @user_data[type] = user_data
      end

      def respond_to_missing?(name, include_private = false)
        @user_data.has_key?(name)
      end

      def self.base_name(name)
        name.sub(/-\d{4}(?:([.-])\d{2}(?:\1\d{2}(?:\1\d{2})?)?)?(?:-\d{5,})?\z/, "")
      end

      def base_name
        @base_name ||= self.class.base_name(name)
      end

      def self.group_name(name)
        name.sub(/-(?<year>\d{4})(?:(?<date_separator>[.-])(?<month>\d{2})(?:\k<date_separator>(?<day>\d{2})(?:\k<date_separator>(?<hour>\d{2}))?)?)?(?<stream_id>-\d{5,})?\Z/) do |match|
          res = "-YYYY"
          res << "#{Regexp.last_match(:date_separator)}MM" if Regexp.last_match(:month)
          res << "#{Regexp.last_match(:date_separator)}dd" if Regexp.last_match(:day)
          res << "#{Regexp.last_match(:date_separator)}HH" if Regexp.last_match(:hour)
          res << "-#{"N" * (Regexp.last_match(:stream_id).length - 1)}" if Regexp.last_match(:stream_id)
          res
        end
      end

      def group_name
        @group_name ||= self.class.group_name(name)
      end

      def periodic?
        base_name != name
      end

      def yearly?
        name =~ /-\d{4}(-\d{5,})?\z/
      end

      def monthly?
        name =~ /-\d{4}([.-])\d{2}(-\d{5,})?\z/
      end

      def daily?
        name =~ /-\d{4}([.-])\d{2}\1\d{2}(-\d{5,})?\z/
      end

      def hourly?
        name =~ /-\d{4}([.-])\d{2}\1\d{2}\1\d{2}(-\d{5,})?\z/
      end

      private def method_missing(name, *args)
        if @user_data.has_key?(name)
          return @user_data[name]
        end
        super
      end
    end
  end
end
