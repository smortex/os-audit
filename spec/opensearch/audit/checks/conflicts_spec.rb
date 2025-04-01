require "spec_helper"

RSpec.describe OpenSearch::Audit::Checks::Conflicts do
  describe "#diff" do
    subject do
      described_class.new(nil).diff(left, right)
    end

    let(:left) do
      {
        "foo" => "bar",
        "bar" => {
          "baz" => "qux"
        }
      }
    end
    let(:right) do
      {
        "foo" => "baz",
        "bar" => {
          "baz" => "qux",
          "qux" => "qux"
        }
      }
    end

    it do
      is_expected.to eq([%(foo: "bar" (last) != "baz" (current)), %(bar.qux: nil (last) != "qux" (current))])
    end
  end
end
