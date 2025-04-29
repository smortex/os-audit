require "spec_helper"

RSpec.describe OpenSearch::Audit::Checks::DynamicMapping do


  describe "#mapping_field_name" do
    subject do
      described_class.new(nil).mapping_field_name(mapping)
    end

    let(:mapping) { "mappings.properties.postfix.properties.smtp.properties.status" }

    it { is_expected.to eq "postfix.smtp.status" }
  end
end
