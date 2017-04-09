require 'spec_helper'
require 'fileutils'
require 'pp'

RSpec.describe 'VimAlternateFile', :vim do
  #let(:verbose) { true }
  let(:config) { @config }

  before(:all) do
    out = run("'g:alternate_file_config'")
    @config = out.last
  end

  describe 'to_dict' do
    shared_examples 'to_dict' do |hash, expected|
      subject { to_dict hash }

      context "given #{hash}" do
        it "returns #{expected}" do
          expect(subject).to eq expected
        end
      end
    end

    it_behaves_like 'to_dict', {foo: 'bar'}, "{'foo':'bar'}"
    it_behaves_like 'to_dict',
      {foo: 'bar', fizz: 'buzz'},
      "{'foo':'bar','fizz':'buzz'}"
    it_behaves_like 'to_dict',
      {a: 'b', c: {d: 'e', f: 'g'}},
      "{'a':'b','c':{'d':'e','f':'g'}}"
  end

  describe '.subdirs' do
    let(:fx) { 'subdirs' }

    before { run_command }

    it 'returns paths with a trailing slash' do
      expect(subject.count).to be > 1

      subject.each do |path|
        expect(path).to match(/\/$/)
      end
    end
  end

  describe '.is_spec_folder' do
    let(:fx)      { 'is_spec_folder' }
    let(:fx_args) { "'%s'" }

    # deprecated, but keeping for example of plain context
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

    it_behaves_like 'is_spec_folder', '/spec/',  1
    it_behaves_like 'is_spec_folder', 'x/spec/', 1
    it_behaves_like 'is_spec_folder', '/spec/x', 0
    it_behaves_like 'is_spec_folder', '/xspec/', 0
    it_behaves_like 'is_spec_folder', '/specx/', 0

    it_behaves_like 'is_spec_folder', '/sPec/',  1
    it_behaves_like 'is_spec_folder', 'x/sPec/', 1
    it_behaves_like 'is_spec_folder', '/sPec/x', 0
    it_behaves_like 'is_spec_folder', '/xsPec/', 0
    it_behaves_like 'is_spec_folder', '/sPecx/', 0

    it_behaves_like 'is_spec_folder', '/test/',  1
    it_behaves_like 'is_spec_folder', 'x/test/', 1
    it_behaves_like 'is_spec_folder', '/test/x', 0
    it_behaves_like 'is_spec_folder', '/xtest/', 0
    it_behaves_like 'is_spec_folder', '/testx/', 0

    it_behaves_like 'is_spec_folder', '/tEst/',  1
    it_behaves_like 'is_spec_folder', 'x/tEst/', 1
    it_behaves_like 'is_spec_folder', '/tEst/x', 0
    it_behaves_like 'is_spec_folder', '/xtEst/', 0
    it_behaves_like 'is_spec_folder', '/tjstx/', 0
  end
end
