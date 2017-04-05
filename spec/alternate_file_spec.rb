require 'spec_helper'
require 'fileutils'

RSpec.describe 'VimAlternateFile' do
  def run_commands(*commands)
    cmds = [
      'redir @a',
      *commands,
      'put = @a',
      'w! >> out.txt',
      'qall!',
    ].flatten.map do |cmd|
      "\"+#{cmd}\""
    end.join ' '

    command = "vi -u spec/.vimrc #{cmds}"
    puts command

    `#{command}`

    File.open('out.txt') do |file|
      file.each_line.with_index do |line, i|
        next unless i > 1
        output << line
      end
    end
  end

  let (:output) { [] }

  before { FileUtils.rm 'out.txt' if File.file?('out.txt') }
  after { FileUtils.rm 'out.txt' if File.file?('out.txt') }

  it 'works' do
    run_commands(
      "echo strftime('%c')",
      "echo strftime('%c')",
      "echo strftime('%c')",
    )
    puts '-' * 80
    puts output
    puts '-' * 80

    expect(true).to eq true
  end

  it 'maybe works' do
    expect(true).to eq true
  end
end
