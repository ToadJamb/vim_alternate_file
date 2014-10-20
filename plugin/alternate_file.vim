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
  execute 'vsplit ' . buffer
endfunction

function! s:OpenClass()
  let buffer = expand('%')
  let buffer = substitute(buffer, '_spec\.', '.', '')
  let buffer = substitute(buffer, '^spec/', '', '')
  execute 'vsplit ' . buffer
endfunction
