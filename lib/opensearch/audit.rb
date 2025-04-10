require "opensearch/audit/index"
require "opensearch/audit/index_group"
require "opensearch/audit/index_list"
require "opensearch/audit/checks/base"

require "active_support/inflector"

module OpenSearch
  module Audit
    def self.add_check(name, &block)
      @checks ||= {}

      klass = Class.new(OpenSearch::Audit::Checks::Base)
      klass.class_exec(&block)
      @checks[name] = klass

      Checks.const_set(name.to_s.classify, klass)
    end

    def self.available_checks
      @checks.keys
    end

    def self.run_enabled_checks(index_list, options)
      @checks.each do |name, klass|
        next unless options[:checks].empty? || options[:checks].include?(name)

        klass.new(index_list, options).check
      end
    end
  end
end

Gem::Specification.latest_specs.map do |spec|
  Dir["#{spec.full_gem_path}/lib/opensearch/audit/checks/*.rb"].each { |f| require f }
end
