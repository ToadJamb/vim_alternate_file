require 'spec_helper'
require 'fileutils'

RSpec.shared_context 'plain', :plain do
  let(:command) { "\\\"#{fx}\\\"" }
end

RSpec.shared_context 'vim', :vim do
  subject { output.first }

  let(:command) { "sid . \\\"#{fx}(#{fx_args})\\\"" }
  let (:output) { [] }
  let(:verbose) { true }
  let(:args)    { '' }

  def run_command
    FileUtils.rm 'spec/out.txt' if File.file?('spec/out.txt')

    puts cmd if verbose
    system cmd

    File.open('spec/out.txt') do |file|
      file.each_line.with_index do |line, i|
        next unless i > 1

        val = eval(line.chomp)
        #val = val.to_i if val.to_i.to_s == val
        #val = val.to_f if val.to_f.to_s == val

        output << val
      end
    end
    FileUtils.rm 'spec/out.txt' if File.file?('spec/out.txt')

    if verbose
      puts '-' * 80
      puts output
      puts '-' * 80
    end

    msg = "expected exactly one line (got #{output.count}):\n" +
      cmd + "\n" +
      '-' * 80 + "\n" +
      output.join("\n")
    expect(output.count).to eq(1), msg
  end

  private

  def cmd
    return @cmd if defined?(@cmd)

    subs =
      if command.match(/\%s/)
        command % args
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
end

RSpec.configure do |rspec|
  rspec.include_context 'vim', :vim
  rspec.include_context 'plain', :plain
end

RSpec.describe 'VimAlternateFile', :vim do
  describe '.is_spec_folder' do
    let(:fx)      { 'is_spec_folder' }
    let(:fx_args) { "'%s'" }

    context 'relies on globpath output', :plain do
      let(:fx)  { "split(globpath(getcwd(), '*/'), '\n')" }

      before { run_command }

      it 'returns paths with a trailing slash' do
        expect(subject.count).to be > 1
        subject.each do |path|
          expect(path).to match(/\/$/)
        end
      end
    end

    shared_examples 'is_spec_folder' do |path, expected|
      let(:args) { path }

      context "given a path of #{path.inspect}" do
        before { run_command }

        it "returns #{expected.inspect}" do
          expect(subject).to eq expected
        end
      end
    end

    it_behaves_like 'is_spec_folder', '/spec/', 1
    it_behaves_like 'is_spec_folder', 'x/spec/', 1
    it_behaves_like 'is_spec_folder', '/spec/x', 0
    it_behaves_like 'is_spec_folder', '/xspec/', 0
    it_behaves_like 'is_spec_folder', '/specx/', 0








    #it_behaves_like 'is_spec_folder', '/spec', 0
    #it_behaves_like 'is_spec_folder', 'spec', 0
    #it_behaves_like 'is_spec_folder', 'spec/', 0


    #it_behaves_like 'is_spec_folder', '/xspec/', 0
    #it_behaves_like 'is_spec_folder', '/specx/', 0
  end
end
