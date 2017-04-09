RSpec.shared_context 'plain', :plain do
  let(:command) { "\\\"#{fx}\\\"" }
end

RSpec.shared_context 'vim', :vim do
  subject { output.first }

  let(:command) { "sid . \\\"#{fx}(#{fx_args})\\\"" }
  let(:fx_args) { nil }
  let (:output) { [] }
  let(:verbose) { false }
  let(:args)    { '' }

  OUTFILE = 'spec/out.txt'

  def run_command
    out = run(cmd(command, args), nil, verbose, output)
    output.push(*out)
  end

  def run(command, args = nil, verbose = nil, output = [])
    remove_output

    vim_commands = cmd(command, args)
    puts vim_commands if verbose
    system vim_commands

    send_output_to output

    output[-1] = eval(output.last)

    finis output, verbose

    output
  end

  private

  def to_dict(hash, string = nil)
    string ||= '{%s}'

    string % hash.map do |k, v|
      val =
        if v.is_a?(Hash)
          to_dict(v)
        else
          val = "'#{v}'"
        end

      "'#{k}':#{val}"
    end.join(',')
  end

  def cmd(command = nil, args = nil)
    return @cmd if defined?(@cmd)


    subs =
      if command.match(/\%s/)
        command % params_from(args)
      else
        command
      end

    cmds = [
      'redir @a',
      'let sid = g:alternate_file_sid',
      "let command = #{subs}",
      "execute 'let val = ' . command",
      "echo val",
      'put = @a',
      'w! >> spec/out.txt',
      'qall!',
    ].flatten.map do |cmd|
      "\"+#{cmd}\""
    end.join ' '

    @cmd = "vi -u spec/.vimrc #{cmds}"
  end

  def params_from(args)
    return [] unless args

    args = [args] unless args.is_a?(Array)
    params = args.map do |arg|
      if arg.is_a?(Hash)
        to_dict arg
      else
        arg
      end
    end

    params
  end

  def send_output_to(output)
    File.open(OUTFILE) do |file|
      file.each_line.with_index do |line, i|
        next unless i > 1

        #val = eval(line.chomp)
        #val = val.to_i if val.to_i.to_s == val
        #val = val.to_f if val.to_f.to_s == val

        output << line.chomp
      end
    end
  end

  def finis(output, verbose)
    remove_output

    if verbose
      puts '-' * 80
      puts output
      puts '-' * 80
    end

    validate_output output

    remove_instance_variable :@cmd
  end

  def validate_output(output)
    msg = "expected exactly one line (got #{output.count}):\n" +
      cmd + "\n" +
      '-' * 80 + "\n" +
      output.join("\n")

    puts msg if output.count != 1
    #expect(output.count).to eq(1), msg
  end

  def remove_output
    FileUtils.rm OUTFILE if File.file?(OUTFILE)
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'vim', :vim
  rspec.include_context 'plain', :plain
end
