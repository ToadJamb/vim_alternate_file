" File:          alternate_file.vim
" Author:        Travis Herrick
" Version:       0.0.2
" Description:   Open a spec/class based on the current file.

function! alternate_file:OpenAlternate()
  let root = substitute(expand('%:h'), '/.*', '', '')

  if root == 'spec'
    execute l:OpenClass()
  else
    execute l:OpenSpec()
  endif
endfunction

function! af:OpenAlternate()
  let message = 'af:OpenAlternate() is being deprecated. '
  let message = message . 'Please use alternate_file:OpenAlternate() instead.'

  echoerr message

  execute alternate_file:OpenAlternate()
endfunction

function! l:OpenSpec()
  let buffer = 'spec/' . expand('%:r') . '_spec.' . expand('%:e')
  execute 'vsplit ' . buffer
endfunction

function! l:OpenClass()
  let buffer = expand('%')
  let buffer = substitute(buffer, '_spec\.', '.', '')
  let buffer = substitute(buffer, '^spec/', '', '')
  execute 'vsplit ' . buffer
endfunction
