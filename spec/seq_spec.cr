require "./spec_helper"

describe Shell::Seq do
  describe "(basic feature)" do
    it "works with sequential commands" do
      shell = Shell::Seq.new
      shell.run("echo OK")
      shell.run("pwd", chdir: "/tmp")
      shell.success?.should be_true
      shell.stdout.should eq("OK\n/tmp\n")
    end
  end

  describe "(composite feature)" do
    it "acts as enumerable for shells" do
      shell = Shell::Seq.new
      shell.run("date")
      shell.run("ls")
      shell.map(&.cmd).should eq(["date", "ls"])
    end

    it "acts as indexable for shells" do
      shell = Shell::Seq.new
      shell.run("date")
      shell.run("ls")
      shell.last.cmd.should eq("ls")
    end

    it "raises IndexError when index is out of bounds" do
      shell = Shell::Seq.new
      expect_raises(IndexError) do
        shell.last.cmd
      end
    end
  end

  describe "(error handling)" do
    describe "#run" do
      it "ignore rest of commands after once command failed" do
        shell = Shell::Seq.new
        shell.run("xxxxx")          # failed
        shell.run("ls")
        shell.failure?.should be_true
        shell.map(&.cmd).should eq(["xxxxx"])
      end
    end

    describe "#run!" do
      it "abort immediately" do
        shell = Shell::Seq.new
        expect_raises(Exception) do
          shell.run!("xxxxx")          # failed
        end
      end
    end
  end

  describe "(stdout feature)" do
    describe "#match!" do
      it "ensure stdout matches to given regex and return MatchData" do
        shell = Shell::Seq.new
        shell.run("echo OK")
        shell.match!(/^(.*?)$/m)[0].should eq("OK")
      end

      it "raises when not matched" do
        shell = Shell::Seq.new
        shell.run("echo OK")
        expect_raises(Shell::Seq::MatchError) do
          shell.match!(/NG/)
        end
      end
    end
  end

  describe "(logging feature)" do
    describe "#log" do
      it "contains all information about 'cmd', 'stdout', 'stderr'" do
        shell = Shell::Seq.new
        shell.run("echo a")
        shell.run("echo b")

        shell.log.should match(/^% echo a$/m)
        shell.log.should match(/^a$/m)
        shell.log.should match(/^% echo b$/m)
        shell.log.should match(/^b$/m)

        shell.stdout.should_not match(/echo a/m)
      end
    end
  end

  describe "(dryrun)" do
    it "stores the commands as manifest without executing them" do
      shell = Shell::Seq.new
      shell.dryrun = true
      shell.run("abc")
      shell.run("ls")
      shell.success?.should be_true
      shell.manifest.should eq("abc\nls\n")
    end
  end

  describe "(instance creation)" do
    describe ".run" do
      it "execute the command and return Shell::Seq instance" do
        shell = Shell::Seq.run("echo a")
        shell.should be_a(Shell::Seq)
        shell.stdout.should eq("a\n")
      end

      it "doesn't raise" do
        shell = Shell::Seq.run("xxxxx")
        shell.should be_a(Shell::Seq)
      end
    end
  end
end
