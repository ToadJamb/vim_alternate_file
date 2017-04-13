" File:          alternate_file.vim
" Author:        Travis Herrick
" Version:       0.0.3
" Description:   Open a spec/class based on the current file.

"let g:alternate_file_config = {
"\ 'loaded': 0,
"\ 'spec': {
"\   'paths': ['.', 'test/**', 'tests/**', 'specs/**', 'spec/**'],
"\   'roots': ['spec', 'test', 'specs', 'tests'],
"\ },
"\
"\
"\
"\
"\
"\
"\
"\}

let s:config = {
\ 'app': {
\   'roots': ['app', 'lib', 'src'],
\ },
\ 'spec': {
\   'roots': ['spec', 'test', 'specs', 'tests'],
\   'suffixes': ['_spec', '_test', '.test'],
\ },
\}
function! s:config()
  return s:config
endfunction



let s:loaded = 0
let g:alternate_file_config = {
\ 'pattern': '%f%s',
\ 'suffixes':  ['_spec', '_test', '.test', 'spec', 'test'],
\ 'skip_config': 0,
\
\ 'app': {
\   'paths': [],
\   'roots': [],
\   'rules': {
\   },
\ },
\
\ 'spec': {
\   'paths': [],
\   'roots': [],
\   'rules': {
\   },
\ },
\}
"\ 'rules': {
"\   'paths': {
"\   },
"\
"\   'vim': {
"\     'exts': [
"\       'rb',
"\       'vim',
"\     ],
"\   },
"\   'es6': {
"\     'exts': [
"\       'es6',
"\       'js',
"\     ],
"\   },
"\
"\   'js': {
"\     'suffix': '.test',
"\     'exts': [
"\       'js',
"\       'es6',
"\     ],
"\   },
"\ },
"\}

function! s:SID()
  let fullname = expand('<sfile>')
  return matchstr(fullname, '<SNR>\d\+_')
endfunction
let g:alternate_file_sid = s:SID()


function! OpenAlternateFile()
  let root = substitute(expand('%:h'), '/.*', '', '')

  let config = g:alternate_file_config
  call s:load_config(config)

  if s:loaded < 2
    return
  endif

  if s:is_spec(expand('%'), config)
    "echom 'opening class'
    call s:OpenClass(config)
  else
    "echom 'opening spec'
    call s:open_spec(expand('%'), config)
  endif
endfunction

function! s:open_spec(buffer, config)
  let spec_patterns = s:spec_file_names_for(a:buffer, '*', a:config)
  let glob_paths    = join(a:config.spec.paths, ',')
  let files         = []

  for spec_pattern in spec_patterns
    let files += split(globpath(glob_paths, spec_pattern), "\n")
  endfor

  for file in reverse(files)
    execute 'vsplit ' . file
  endfor

  if len(files) == 0
    let default = s:default_spec_file(a:buffer, a:config)
    execute 'vsplit ' . default
  endif
endfunction

function! s:OpenClass(config)
  let buffer = expand('%')
  let path   = ''

  " this should be smart and look for file extension suffixes first
  for suffix in a:config.suffixes
    let suffix .= '\.'

    if buffer =~? suffix
      let path = substitute(buffer, suffix, '.', '')
      break
    endif
  endfor

  for root in a:config.spec.roots
    let root = '^' . root . '\/'
    "echo root

    if path =~? root
      "echo 'subbing root....'
      let path = substitute(path, root, '', '')
      "echo path
      break
    endif
  endfor

  "let buffer = substitute(buffer, '_spec\.', '.', '')
  "let buffer = substitute(buffer, '^spec/', '', '')

  let glob_paths = '.,' . join(s:config.app.roots, '/**,') . '/**'
  let files = split(globpath(glob_paths, path), "\n")

  "echo glob_paths
  "echo path

  for file in reverse(files)
    "echo file
    execute 'vsplit ' . file
  endfor

  "if len(files) == 0
  "  echo 'single'
  "  echo file
  "  execute 'vsplit ' . path
  "endif
endfunction

function! s:is_spec(path, config)
  for suffix in a:config.suffixes
    if a:path =~? suffix . '\.'
      return 1
    endif
  endfor

  return 0
endfunction

" tested (lightly)
function! s:load_config(config)
  if s:loaded > 0
    return
  endif

  let s:loaded += 1

  "call s:load_global_file()
  call s:load_file(s:project_file(s:root_directory()))

  if !a:config.skip_config
    call s:load_spec_paths(s:subdirs(), s:config, a:config)
  endif

  let s:loaded += 1
endfunction

" tested (lightly)
function! s:load_file(path)
  if !filereadable(a:path)
    return
  endif

  "echo a:path

  execute 'source ' . a:path
endfunction

" tested
function! s:project_file(root)
  let filename = '.vim_alternate_file.' . a:root . '.vim'
  let path     = '~/' . filename

  return fnamemodify(path, ':p')
endfunction

" tested (lightly)
function! s:root_directory()
  let root = getcwd()
  let root = fnamemodify(root, ':t')

  return root
endfunction

" tested
function! s:default_spec_file(file, config)
  let spec = a:file

  let file = s:spec_file_names_for(a:file, '', a:config)[0]

  let paths = get(a:config.spec.rules, 'paths', {})
  for path in items(paths)
    let key = path[0]
    let root = path[1]

    if spec =~? key
      let spec = root . '/' . spec
      break
    end
  endfor

  let spec = a:config.spec.roots[0] . '/' . spec

  return fnamemodify(spec, ':h') . '/' . file
endfunction

" tested
function! s:spec_file_names_for(path, ext, config)
  let file = fnamemodify(a:path, ':t')
  let fext = fnamemodify(file, ':e')
  let file = substitute(file, '.' . fext, '', '')

  let exts = get(a:config.spec.rules, fext, a:config)
  let suffixes = get(exts, 'suffixes', a:config.suffixes)

  let file = substitute(a:config.pattern, '%f', file, '')

  let files = []

  if a:ext == '*'
    for suffix in suffixes
      let spec = substitute(file, '%s', suffix, '')
      let spec .= '.' . a:ext
      call add(files, spec)
    endfor
  else
    let spec = substitute(file, '%s', suffixes[0], '')
    let spec .= '.' . fext

    call add(files, spec)
  endif

  return files
endfunction

" tested
" config is default config
function! s:load_spec_paths(subdirs, default, config)
  let paths = filter(a:subdirs, 's:is_spec_folder(v:val, a:default.spec.roots)')

  for path in paths
    let root = fnamemodify(path, ':h:t')

    call add(a:config.spec.paths, root . '/**')
    call add(a:config.spec.roots, root)
  endfor

  if len(a:config.spec.paths) == 0
    let root = '.'

    call add(a:config.spec.paths, root)
    call add(a:config.spec.roots, root)
  endif

  return a:config
endfunction

" tested (loosely)
function! s:subdirs()
  return split(globpath(getcwd(), '*/'), '\n')
endfunction

" tested
function! s:is_spec_folder(candidate, paths)
  let found = 0

  for path in a:paths
    if a:candidate =~? '/' . path . '/$'
      let found = 1
      break
    end
  endfor

  return found
endfunction
