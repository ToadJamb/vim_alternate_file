" File:          alternate_file.vim
" Author:        Travis Herrick
" Version:       0.0.3
" Description:   Open a spec/class based on the current file.

function! OpenAlternateFile()
  let root = substitute(expand('%:h'), '/.*', '', '')

  if root == 'spec'
    execute s:OpenClass()
  else
    execute s:OpenSpec()
  endif
endfunction

function! s:OpenSpec()
  let buffer = 'spec/' . expand('%:r') . '_spec.' . expand('%:e')
  let filename = substitute(expand('%:t'), '\.' . expand('%:e'), '', '')
  let specFile = filename . '_spec.*'
  ". expand('%:e')

  let list = split(globpath('spec/**/', specFile), "\n")
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
  execute 'vsplit ' . buffer
endfunction
