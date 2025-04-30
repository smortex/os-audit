require "spec_helper"

require "json"

RSpec.describe OpenSearch::Audit::Checks::DynamicMapping do
  describe "#mapping_field_name" do
    subject do
      described_class.new(nil).mapping_field_name(mapping)
    end

    let(:mapping) { "mappings.properties.postfix.properties.smtp.properties.status" }

    it { is_expected.to eq "postfix.smtp.status" }
  end

  describe "#int_range" do
    subject { described_class.new(nil).int_range(["3", "42", "-1", "12", "-7", "0"]) }

    it { is_expected.to eq(-7..42) }
  end

  describe "#detect_field_type" do
    subject { described_class.new(nil).detect_field_type(response) }

    let(:response) do
      JSON.parse(File.read(fixture))
    end

    context "with booleans" do
      let(:fixture) { "spec/fixtures/checks/dynamic_mapping/boolean.json" }

      it { is_expected.to eq("boolean") }
    end

    context "with numbers" do
      let(:fixture) { "spec/fixtures/checks/dynamic_mapping/numbers.json" }

      it { is_expected.to eq("byte") }
    end

    context "with large numbers" do
      let(:fixture) { "spec/fixtures/checks/dynamic_mapping/large_numbers.json" }

      it { is_expected.to eq("long") }
    end

    context "with uids" do
      let(:fixture) { "spec/fixtures/checks/dynamic_mapping/uids.json" }

      it { is_expected.to eq("keyword") }
    end

    context "with hostnames" do
      let(:fixture) { "spec/fixtures/checks/dynamic_mapping/hostnames.json" }

      it { is_expected.to eq("keyword") }
    end
  end
end
