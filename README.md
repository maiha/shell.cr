# shell [![Build Status](https://travis-ci.org/maiha/shell.cr.svg?branch=master)](https://travis-ci.org/maiha/shell.cr)

Small simplistic helper class for executing shell commands in Crystal:

- run command,
- exit if it fails,
- return STDOUT of the command;
- optionally
  - allow to ignore failure
  - return STDERR of failed command.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  shell:
    github: maiha/shell.cr
    version: 0.2.1
```


## Usage


```crystal
require "shell"
```

Output of the shell command is available through `#stdout` and `#stderr`
methods, numeric value of the exit status returned by the function `#run`.

Simplest usage of the `#run` method:

```crystal
puts Shell.run("ls").stdout
```


If command fails `Shell` raises exception, but this behaviour can be
overridden by `fail_on_error` variable:

```crystal
puts Shell.run("command_with_non_zero_status", fail_on_error: false).stderr
```

### Shell::Seq

`Shell::Seq` accumulates shell commands and those results.
When an error occur, '#run' doesn't raise any errors and just skips latter commands.
This is similar to Try monad concatinations.

```crystal
shell = Shell::Seq.new
shell.run("mkdir /tmp/shell") if !Dir.exists?("/tmp/shell")
shell.run("git clone https://github.com/maiha/shell.cr.git", chdir: "/tmp/shell")
shell.run("ls /xxxxx")
shell.run("date")

shell.success?            # => false
shell.last.stderr         # => "ls: cannot access '/xxxxx': No such file or directory\n"
shell.map(&.cmd.split[0]) # => ["mkdir", "git", "ls"]
shell.log                 # shows `cmd`, `stdout`, `stderr` of all executed commands
# % mkdir /tmp/shell
# % git clone https://github.com/maiha/shell.cr.git
# Cloning into 'shell.cr'...
# % ls /xxxxx
# ls: cannot access '/xxxxx': No such file or directory
```

See test for further usage: [spec/seq_spec.cr](spec/seq_spec.cr)

## Contributing

1. Fork it ( https://github.com/dmytro/shell/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [dmytro](https://github.com/dmytro) Dmytro Kovalov - creator, maintainer
