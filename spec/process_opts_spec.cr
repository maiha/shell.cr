require "./spec_helper"

Spec2.describe "compatible with Process options" do

  describe "#chdir" do
    it "changes directory before running the command" do
      absolute = Shell.new("ls /bin").run.split(/\n/).sort
      relative = Shell.new("ls .", chdir: "/bin").run.split(/\n/).sort
      expect(relative).to eq(absolute)
    end
  end

  describe ".run" do
    it "should respect options" do
      expect {
        Shell.run("ls .", chdir: "/bin")
      }.not_to raise_error Exception
    end
  end
end
