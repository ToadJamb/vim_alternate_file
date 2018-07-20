require 'spec_helper'
require 'fileutils'
require 'pp'
require 'deep_clone'

RSpec.describe 'VimAlternateFile', :vim do
  $VERBOSE = nil
  #let(:verbose) { true }
  $VERBOSE = true

  let(:config)       { DeepClone.clone @config }
  let(:local_config) { DeepClone.clone @local_config }

  before(:all) do
    out = run("'g:alternate_file_config'")
    @config = out.last
    out = run("sid . 'config()'")
    @local_config = out.last
  end

  def set_base_suffixes(suffixes)
    config[:suffixes] = suffixes
  end

  def set_spec_paths(paths)
    config[:spec][:paths] = paths
  end

  def set_spec_roots(roots)
    config[:spec][:roots] = roots
  end

  def set_spec_rule_paths(paths)
    config[:spec][:rules][:paths] = paths
  end

  #describe 'debugging' do
  #  describe '.open_spec' do
  #    let(:fx)      { 'open_spec' }
  #    let(:fx_args) { "'%s', %s" }

  #    before { set_base_suffixes ['_spec'] }
  #    before { set_spec_roots ['spec'] }
  #    before { set_spec_paths ['spec/**'] }

  #    it 'works' do
  #      run_command 'plugin/alternate_file.vim', config
  #    end
  #  end
  #end

  describe '.config' do
    subject { config }

    it 'has the expected keys' do
      expect(config.keys).to match_array [
        :pattern,
        :suffixes,
        :skip_config,
        :app,
        :spec,
      ]
    end

    describe '.pattern' do
      it 'returns "%f%s"' do
        expect(config[:pattern]).to eq '%f%s'
      end
    end

    describe '.app' do
      subject { config[:spec] }

      it 'has the expected keys' do
        expect(subject.keys).to match_array [:paths, :roots, :rules]
      end
    end

    describe '.spec' do
      subject { config[:spec] }

      it 'has the expected keys' do
        expect(subject.keys).to match_array [:paths, :roots, :rules]
      end
    end
  end

  describe '.load_config' do
    let(:fx)      { 'load_config' }
    let(:fx_args) { '%s' }

    it 'works' do
      run_command config
    end
  end

  describe '.root_directory' do
    let(:fx) { 'root_directory' }

    context 'by default' do
      before { run_command }

      it "returns #{File.basename Dir.pwd}" do
        expect(subject).to eq File.basename(Dir.pwd)
        expect(subject).to_not match(/\//)
      end
    end
  end

  describe '.project_file' do
    let(:fx)      { 'project_file' }
    let(:fx_args) { "'%s'" }

    shared_examples 'project file' do |root, expected|
      context "given the current root is #{root}" do
        before { run_command root }

        it "returns #{expected}" do
          expect(subject).to eq File.expand_path(expected)
        end
      end
    end

    it_behaves_like 'project file', 'foo', '~/.vim_alternate_file.foo.vim'
    it_behaves_like 'project file', 'bar', '~/.vim_alternate_file.bar.vim'
  end

  describe '.default_spec_file' do
    let(:fx)      { 'default_spec_file' }
    let(:fx_args) { "'%s', %s" }

    shared_examples 'default_spec_file' do |file,suffixes,roots,paths,expected|
      context "given a file #{file}" do
        context "given suffixes #{suffixes}" do
          before { set_base_suffixes suffixes }

          context "given roots #{roots}" do
            before { set_spec_roots roots }

            context "given path specs of #{paths}" do
              before { set_spec_rule_paths paths if paths }

              before { run_command file, config }

              it "returns #{expected}" do
                expect(subject).to eq expected
              end
            end
          end
        end
      end
    end

    it_behaves_like 'default_spec_file',
      'app/models/foo.rb',
      ['_spec'], ['spec'], {
      '^app/' => '..',
    }, 'spec/../app/models/foo_spec.rb'

    it_behaves_like 'default_spec_file',
      'lib/my_lib/models/foo.rb',
      ['_spec'], ['spec'], {
      '^lib/my_lib/' => '../..',
    }, 'spec/../../lib/my_lib/models/foo_spec.rb'

    it_behaves_like 'default_spec_file',
      'lib/my_lib/models/foo.rb',
      ['.test', '_spec'], ['.'], {
    }, './lib/my_lib/models/foo.test.rb'

    it_behaves_like 'default_spec_file',
      'lib/my_lib/models/foo.rb',
      ['.test', '_spec'], ['.'], nil,
      './lib/my_lib/models/foo.test.rb'
  end

  describe '.spec_file_names_for' do
    let(:fx)      { 'spec_file_names_for' }
    let(:fx_args) { "'%s', '%s', %s" }

    shared_examples 'spec_file_names_for' do |path,ext,pattern,suffix,expected|
      let(:rules) { config[:spec][:rules] }

      context "given the file path is: #{path}" do
        let(:path_ext) { File.extname(path)[1..-1].to_sym }

        context "given the extension is #{ext}" do
          context "given the pattern is #{pattern}" do
            before { config[:pattern] = pattern }

            context "given the suffix is #{suffix}" do
              context 'given the suffix is set at the root' do
                before { config[:suffixes] = suffix }

                context 'given the suffix is set for the extension' do
                  before { config[:suffixes] = ['x' + ext + 'x'] }

                  before { rules[path_ext] ||= {} }
                  before { rules[path_ext][:suffixes] = suffix }

                  it "returns #{expected}" do
                    run_command path, ext, config
                    expect(subject).to eq expected
                  end
                end

                context 'given the suffix is not set for the extension' do
                  before { expect(rules[path_ext]).to eq nil }

                  it "returns #{expected}" do
                    run_command path, ext, config
                    expect(subject).to be_an Array
                    expect(subject).to eq expected
                  end

                  context 'given the extension has other settings' do
                    before { rules[path_ext] ||= {} }

                    it "returns #{expected}" do
                      run_command path, ext, config
                      expect(subject).to be_an Array
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

    it_behaves_like 'spec_file_names_for',
      'path/to/my_file.foo', '*', '%f%s', ['sPec'], ['my_filesPec.*']
    it_behaves_like 'spec_file_names_for',
      'path/to/my_file.foo', '', '%s%f', ['sPec', 'tEst'], ['sPecmy_file.foo']
    it_behaves_like 'spec_file_names_for',
      'path/to/stuff.js', '*', '%f%s',
      ['.tEst', '_teSt'],
      ['stuff.tEst.*', 'stuff_teSt.*']
    it_behaves_like 'spec_file_names_for',
      'lib/my_lib/irb.rb', '', '%f%s', ['_spec'], ['irb_spec.rb']
  end

  describe '.load_spec_paths' do
    let(:fx)      { 'load_spec_paths' }
    let(:fx_args) { '%s, %s, %s' }

    # it is possible for this spec to break due
    # to folder structure/name changes within the project
    context 'by default' do
      let(:subdirs) { Dir['*/'].map { |d| "foo/#{d}" } }

      before do
        expect(local_config[:spec][:roots])
          .to match_array ['spec', 'specs', 'test', 'tests']
      end

      before { run_command subdirs, local_config, config }

      it 'sets the roots to only the (existing) spec folder' do
        expect(subject[:spec][:roots]).to eq ['spec']
      end
    end

    shared_examples 'load_spec_paths' do |dirs, paths, exp_paths, exp_roots|
      context "given subdirs are: #{dirs}" do
        let(:dir_params) { dirs.map { |d| "x/#{d}/" } }

        context "given spec paths are: #{paths}" do
          before { local_config[:spec][:roots] = paths }

          before { run_command dir_params, local_config, config }

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

  #describe '.spec_folders_for' do
  #  let(:fx)      { 'spec_folders_for' }
  #  let(:fx_args) { "'%s', %s" }

  #  shared_examples 'spec_folders_for' do |buffer, config, expected|
  #    context "given a buffer of #{buffer.inspect}" do
  #      context "given a config: #{config.inspect}" do
  #        before { run_command buffer, config}

  #        it "returns #{expected.inspect}" do
  #          expect(subject).to eq expected
  #        end
  #      end
  #    end
  #  end

  #  #it_behaves_like 'spec_folders_for',
  #  #  'hm/lib/hm/foo.exs',
  #  #  {
  #  #    :spec => {
  #  #      :paths => ['foo/bar'],
  #  #    },
  #  #  },
  #  #  ['foo/bar']
  #  it_behaves_like 'spec_folders_for',
  #    'plugin/alternate_file.vim',
  #    {
  #      :spec => {
  #        :roots => ['spec', 'test', 'specs', 'tests'],
  #        :paths => ['foo/bar'],
  #      },
  #    },
  #    ['foo/bar']
  #end
end
