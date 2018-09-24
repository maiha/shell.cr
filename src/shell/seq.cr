class Shell::Seq
  class MatchError < Exception; end
  
  include Indexable(Shell)
  delegate size, unsafe_at, to: @shells

  getter status
  delegate exit_code, success?, to: @status

  property? abort_on_error
  property? dryrun : Bool = false
  
  def initialize(@stdout : IO = IO::Memory.new,
                 @stderr : IO = IO::Memory.new,
                 @abort_on_error = false)
    @shells   = [] of Shell
    @status   = Process::Status.new(0)
    @manifest = IO::Memory.new
  end

  def run(*args, **options)
    return unless @status.success?

    @shells << (shell = Shell.new(*args, **options))
    shell.fail_on_error = abort_on_error?
    if dryrun?
      @manifest.puts shell.cmd
    else
      shell.run
    end
    @status = shell.status
    @stdout.print shell.stdout
    @stderr.print shell.stderr
  end

  def run!(*args, **options)
    old = abort_on_error?
    begin
      @abort_on_error = true
      run(*args, **options)
    ensure
      @abort_on_error = old
    end
  end

  def stdout   : String ; @stdout.to_s ; end
  def stderr   : String ; @stderr.to_s ; end
  def failure? : Bool   ; !success?    ; end

  def match!(r : Regex)
    stdout.match(r) || raise MatchError.new("MatchError: '%s'\n%s" % [r.source, log])
  end

  def manifest
    @manifest.to_s
  end

  def log : String
    String.build do |s|
      each do |shell|
        s.puts "% #{shell.cmd}"
        s << shell.stdout
        s << shell.stderr
      end
    end
  end
end

class Shell::Seq
  def self.run(*args, **options)
    new.tap(&.run(*args, **options))
  end
end
