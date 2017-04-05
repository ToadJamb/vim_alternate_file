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


let s:loaded = 0
let g:alternate_file_config = {
\ 'spec': {
\   'paths': [],
\   'roots': [],
\ },
\
\
\
\
\
\
\
\}

function! OpenAlternateFile()
  let root = substitute(expand('%:h'), '/.*', '', '')

  let config = g:alternate_file_config
  call s:load_config(config)

  if s:loaded < 2
    return
  endif

  "if root == config.spec.roots
  "  call s:OpenClass(config)
  "else
    call s:OpenSpec(config)
  "endif
endfunction

function! s:OpenSpec(config)
  let buffer = 'spec/' . expand('%:r') . '_spec.' . expand('%:e')

  let filename = substitute(expand('%:t'), '\.' . expand('%:e'), '', '')
  let specFile = filename . '_spec.*'

  let glob_paths = join(a:config.spec.paths, ',')
  let list = split(globpath(glob_paths, specFile), "\n")
  for path in list
    execute 'vsplit ' . path
  endfor

  if len(list) == 0
    execute 'vsplit ' . buffer
  endif
endfunction

function! s:OpenClass()
  let buffer = expand('%')
  let buffer = substitute(buffer, '_spec\.', '.', '')
  let buffer = substitute(buffer, '^spec/', '', '')

  let paths = [
  \ 'src',
  \ 'lib',
  \ 'app',
  \]

  let glob_paths = '.,' . join(paths, '/**,') . '/**'
  let list = split(globpath(glob_paths, buffer), "\n")
  for path in list
    execute 'vsplit ' . path
  endfor

  if len(list) == 0
    execute 'vsplit ' . buffer
  endif
endfunction

function! s:load_config(config)
  if s:loaded > 0
    return
  endif

  let s:loaded += 1

  call s:load_spec_paths(a:config)

  call s:load_project_file()

  let s:loaded += 1
endfunction

function s:load_spec_paths(config)
  let paths = split(globpath(getcwd(), '*/'), '\n')
  let paths = filter(paths, 's:is_spec_folder(v:val)')

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
endfunction

function! s:load_project_file()
  echom s:project_file()
endfunction

function! s:root_directory()
  let root = getcwd()
  let root = fnamemodify(root, ':t')

  return root
endfunction

function! s:project_file()
  let root     = s:root_directory()
  let filename = '.vim_alternate_file.' . root . '.vim'
  let path     = '~/' . filename

  return fnamemodify(path, ':p')
endfunction

function! s:is_spec_folder(path)
  return a:path =~ '/specs\?/$' || a:path =~ '/tests\?/$'
endfunction
