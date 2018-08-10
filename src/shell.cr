class Shell

  def initialize(@cmd : String,
                 @args : Array(String)? = nil,
                 @stdout : Process::Stdio = IO::Memory.new,
                 @stderr : Process::Stdio = IO::Memory.new,
                 @stdin : Process::Stdio = Process::Redirect::Close,
                 @chdir : String? = nil,
                 @env : Process::Env = nil,
                 @clear_env : Bool = false,
                 @fail_on_error : Bool = true
                )
    @status = Process::Status.new(0)
  end

  getter cmd
  getter status
  property? fail_on_error
  delegate exit_code, success?, to: @status

  def stdout
    @stdout.to_s
  end

  def stderr
    @stderr.to_s
  end

  def failed? : Bool
    !success?
  end

  def should_fail? : Bool
    failed? && fail_on_error?
  end

  def fail
    raise "Shell command failed (status: #{exit_code}) with an error: \n" + stderr
  end

  def run() : String
    @status = Process.run(@cmd,
                          args: @args,
                          env: @env,
                          clear_env: @clear_env,
                          shell: true,
                          input: @stdin,
                          output: @stdout,
                          error: @stderr,
                          chdir: @chdir)

    fail if should_fail?

    stdout
  end

  macro run(*args, **options)
    Shell.new({{*args}}, {{**options}}).run
  end
end

require "./shell/*"
