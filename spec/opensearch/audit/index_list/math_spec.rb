require "spec_helper"

RSpec.describe OpenSearch::Audit::IndexList::Math do
  context "#median" do
    subject do
      obj = Object.new
      obj.extend(OpenSearch::Audit::IndexList::Math)
      obj.median(values)
    end

    {
      [42] => 42,
      [1, 7, 42] => 7,
      [1, 2, 1000, 8000] => 501
    }.each do |args, expected|
      context "with #{args.inspect}" do
        let(:values) { args }

        it { is_expected.to eq(expected) }
      end
    end
  end
end
