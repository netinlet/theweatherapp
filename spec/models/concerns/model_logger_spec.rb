require "rails_helper"

class TestModelLogger
  include ModelLogger
end

RSpec.describe TestModelLogger do
  let(:subject) { TestModelLogger.new }

  it "attaches a logger to the instance" do
    expect(subject.logger).to eq(Rails.logger)
  end

  it "attaches a logger to the class" do
    expect(TestModelLogger.logger).to eq(Rails.logger)
  end
end
