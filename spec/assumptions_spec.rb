require 'spec_helper'
require 'pp'

RSpec.describe 'assumes', :vim do
  describe 'hashes' do
    let(:data) {{
      :author => {
        :name => 'author-name',
        :posts => [
          'post-1', 'post-2'
        ],
      }
    }}

    it 'leaves nested hashes intact' do
      c1 = DeepClone.clone(data)
      c2 = DeepClone.clone(data)

      c1[:author][:name] = 'foo-bar'

      expect(c1[:author][:name]).to eq 'foo-bar'
      expect(c2[:author][:name]).to eq 'author-name'
      expect(data[:author][:name]).to eq 'author-name'
    end

    it 'leaves nested arrays intact' do
      c1 = DeepClone.clone(data)
      c2 = DeepClone.clone(data)

      c1[:author][:posts] << 'post-3'

      expect(c1[:author][:posts]).to match_array ['post-1', 'post-2', 'post-3']
      expect(c2[:author][:posts]).to match_array ['post-1', 'post-2']
      expect(data[:author][:posts]).to match_array ['post-1', 'post-2']
    end
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
    it_behaves_like 'to_dict', {a: ['b', 'c']}, "{'a':['b','c']}"
  end

  # deprecated, but keeping for example of plain context
  # this was originally meant as a dependeny for `is_spec_folder()`.
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
end
