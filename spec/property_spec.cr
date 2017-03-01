require "./spec_helper"

Spec2.describe "Shell (properties)" do

  describe "#cmd" do
    it "returns cmd itself" do
      expect(Shell.new("ls").cmd).to eq("ls")
    end
  end

  describe "#fail_on_error?" do
    it "returns true in default" do
      expect(Shell.new("ls").fail_on_error?).to eq(true)
    end

    it "can be overwritten" do
      shell = Shell.new("ls")
      shell.fail_on_error = false
      expect(shell.fail_on_error?).to eq(false)
    end
  end

  describe "#status" do
    it "returns Process::Status" do
      expect(Shell.new("ls").status.class).to eq(Process::Status)
    end
  end

  describe "#exit_code" do
    it "returns Int32" do
      expect(Shell.new("ls").exit_code).to eq(0)
    end
  end
end
