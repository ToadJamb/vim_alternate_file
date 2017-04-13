RSpec.shared_context 'plain', :plain do
  let(:command) { "\\\"#{fx}\\\"" }
end

RSpec.shared_context 'vim', :vim do
  subject { output.last }

  let(:command) { "sid . \\\"#{fx}(#{fx_args})\\\"" }
  let(:fx_args) { nil }
  let (:output) { [] }
  let(:verbose) { false }

  OUTFILE = 'spec/out.txt'

  after do
    errors = output.any? do |line|
      line.is_a?(String) &&
        (line.match(/error/i) ||
        line.match(/^E\d.*:/))
    end

    msg = ''
    msg = output.join("\n") unless verbose

    expect(errors).to eq(false), msg
  end

  def run_command(*args)
    run cmd(command, args), nil, verbose, output
  end

  def run(command, args = nil, verbose = nil, output = [])
    remove_output

    vim_commands = cmd(command, args)
    if verbose
      puts
      puts '=' * 80
      puts vim_commands
    end
    system vim_commands

    send_output_to output

    begin
      output[-1] = eval(output.last)
    rescue Exception => e
      if verbose
        puts '-' * 80
        puts "#{e.class}: eval could not be called on: `#{output.last}`"
      end
    end

    finis output, verbose

    output
  end

  def to_dict(data)
    raise 'Expected array or hash' unless [Hash, Array].include?(data.class)
    method = "to_#{data.class.to_s.downcase}"
    send method, data
  end

  private

  def to_hash(data)
    raise 'Expected hash' unless data.is_a?(Hash)

    '{%s}' % data.map do |k, v|
      val = dict_value_for(v)

      "'#{k}':#{val}"
    end.join(',')
  end

  def to_array(data)
    raise 'Expected array' unless data.is_a?(Array)

    '[%s]' % data.map do |v|
      dict_value_for(v)
    end.join(',')
  end

  def dict_value_for(value)
    if [Hash, Array].include?(value.class)
      to_dict(value)
    else
      "'#{value}'"
    end
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
      if arg.is_a?(Hash) || arg.is_a?(Array)
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
      puts '=' * 80
    end

    validate_output output, verbose

    remove_instance_variable :@cmd
  end

  def validate_output(output, verbose)
    msg = '=' * 80 + "\n" +
      "expected exactly one line (got #{output.count}):\n" +
      cmd + "\n" +
      '-' * 80 + "\n" +
      output.join("\n") + "\n" +
      '=' * 80

    puts msg if output.count != 1 && !verbose
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
