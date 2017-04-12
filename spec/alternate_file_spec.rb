require 'spec_helper'
require 'fileutils'
require 'pp'
require 'deep_clone'

RSpec.describe 'VimAlternateFile', :vim do
  #let(:verbose) { true }
  let(:config) { DeepClone.clone @config }

  before(:all) do
    out = run("'g:alternate_file_config'")
    @config = out.last
  end

  describe 'debugging' do
    let(:fx)      { 'open_spec' }
    let(:fx_args) { '%s' }

    it 'works' do
      run_command config
    end
  end

  describe '.confg' do
    subject { config }

    it 'has the expected keys' do
      expect(config.keys).to match_array [:spec, :app_folders, :rules]
    end

    describe '.spec' do
      subject { config[:spec] }

      it 'has the expected keys' do
        expect(subject.keys).to match_array [:roots, :paths]
      end

      describe '.paths' do
        subject { config[:spec][:paths] }

        it 'has the expected default values' do
          expect(subject).to match_array ['spec', 'specs', 'test', 'tests']
        end
      end
    end

    #describe '.rules' do
    #  subject { config[:rules] }

    #  it 'has the expected keys' do
    #    expect(subject.keys).to match_array [:pattern, :suffix]
    #  end

    #  #describe '.paths' do
    #  #  subject { config[:spec][:paths] }

    #  #  it 'has the expected default values' do
    #  #    expect(subject).to match_array ['spec', 'specs', 'test', 'tests']
    #  #  end
    #  #end
    #end
  end

  describe '.default_spec_file' do
    let(:fx)      { 'default_spec_file' }
    let(:fx_args) { "'%s', %s" }

    shared_examples 'default_spec_file' do |file, roots, paths, expected|
      context "given a file #{file}" do
        context "given roots #{roots}" do
          before { config[:spec][:roots] = roots }

          context "given path specs of #{paths}" do
            before { config[:rules][:paths] = paths }

            before { run_command file, config }

            it "returns #{expected}" do
              expect(subject).to eq expected
            end
          end
        end
      end
    end

    it_behaves_like 'default_spec_file', 'app/models/foo.rb', ['spec'], {
      '^app/' => '..',
    }, 'spec/../app/models/foo_spec.rb'
    it_behaves_like 'default_spec_file', 'lib/my_lib/models/foo.rb', ['spec'], {
      '^lib/my_lib/' => '../..',
    }, 'spec/../../lib/my_lib/models/foo_spec.rb'
    it_behaves_like 'default_spec_file', 'lib/my_lib/models/foo.rb', ['.'], {
    }, './lib/my_lib/models/foo_spec.rb'
  end

  describe '.spec_file_name_for' do
    let(:fx)      { 'spec_file_name_for' }
    let(:fx_args) { "'%s', '%s', %s" }

    shared_examples 'spec_file_name_for' do |path,ext,pattern,suffix,expected|
      context "given the file path is: #{path}" do
        let(:path_ext) { File.extname(path)[1..-1] }

        context "given the extension is #{ext}" do
          context "given the pattern is #{pattern}" do
            before { config[:rules][:pattern] = pattern }

            context "given the suffix is #{suffix}" do
              context 'given the suffix is set at the root' do
                before { config[:rules][:suffix] = suffix }

                context 'given the suffix is set for the extension' do
                  before { config[:rules][:suffix] = 'x' + ext + 'x' }

                  before { config[:rules][path_ext.to_sym] ||= {} }
                  before { config[:rules][path_ext.to_sym][:suffix] = suffix }

                  it "returns #{expected}" do
                    run_command path, ext, config
                    expect(subject).to eq expected
                  end
                end

                context 'given the suffix is not set for the extension' do
                  before { expect(config[:rules][path_ext.to_sym]).to eq nil }

                  it "returns #{expected}" do
                    run_command path, ext, config
                    expect(subject).to eq expected
                  end

                  context 'given the extension has other settings' do
                    before { config[:rules][path_ext.to_sym] ||= {} }

                    it "returns #{expected}" do
                      run_command path, ext, config
                      expect(subject).to eq expected
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    it_behaves_like 'spec_file_name_for',
      'path/to/my_file.foo', 'bar', '%f%s', 'sPec', 'my_filesPec.bar'
    it_behaves_like 'spec_file_name_for',
      'path/to/my_file.foo', 'bar', '%s%f', 'sPec', 'sPecmy_file.bar'
    it_behaves_like 'spec_file_name_for',
      'path/to/stuff.c', 'h', '%f%s', '.tEst', 'stuff.tEst.h'
  end

  describe '.load_spec_paths' do
    let(:fx)      { 'load_spec_paths' }
    let(:fx_args) { '%s, %s' }

    # it is possible for this spec to break due
    # to folder structure/name changes within the project
    context 'by default' do
      let(:subdirs) { Dir['*/'].map { |d| "foo/#{d}" } }

      before do
        expect(config[:spec][:paths])
          .to match_array ['spec', 'specs', 'test', 'tests']
      end

      before { run_command subdirs, config }

      it 'sets the roots to only the (existing) spec folder' do
        expect(subject[:spec][:roots]).to eq ['spec']
      end
    end

    shared_examples 'load_spec_paths' do |dirs, paths, exp_paths, exp_roots|
      context "given subdirs are: #{dirs}" do
        let(:dir_params) { dirs.map { |d| "x/#{d}/" } }

        context "given spec paths are: #{paths}" do
          before { config[:spec][:paths] = paths }

          before { run_command dir_params, config }

          it "returns paths: #{exp_paths} and roots: #{exp_roots}" do
            expect(subject[:spec][:paths]).to match_array exp_paths
            expect(subject[:spec][:roots]).to match_array exp_roots
          end
        end
      end
    end

    it_behaves_like 'load_spec_paths',
      ['foo', 'bar'], ['foo'],
      ['foo/**'], ['foo']
    it_behaves_like 'load_spec_paths',
      ['foo', 'bar'], ['foo', 'bar', 'fizz'],
      ['foo/**', 'bar/**'], ['foo', 'bar']
    it_behaves_like 'load_spec_paths',
      ['foo', 'bar'], ['fizz'],
      ['.'], ['.']
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
    let(:fx_args) { "'%s', %s" }

    shared_examples 'is_spec_folder' do |path, paths, expected|
      context "given a path of #{path.inspect}" do
        context "given expected paths: #{paths.inspect}" do
          before { run_command path, paths}

          it "returns #{expected.inspect}" do
            expect(subject).to eq expected
          end
        end
      end
    end

    it_behaves_like 'is_spec_folder', 'x/spec/', ['spec', 'test'], 1
    it_behaves_like 'is_spec_folder', '/spec/x/', ['spec', 'test'], 0
    it_behaves_like 'is_spec_folder', '/xspec/', ['spec', 'test'], 0
    it_behaves_like 'is_spec_folder', '/specx/', ['spec', 'test'], 0

    it_behaves_like 'is_spec_folder', 'x/sPec/', ['spec', 'test'], 1
    it_behaves_like 'is_spec_folder', '/sPec/x/', ['spec', 'test'], 0
    it_behaves_like 'is_spec_folder', '/xsPec/', ['spec', 'test'], 0
    it_behaves_like 'is_spec_folder', '/sPecx/', ['spec', 'test'], 0

    it_behaves_like 'is_spec_folder', 'x/foo/', ['foo', 'test'], 1
  end
end
