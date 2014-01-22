" File:          alternate_file.vim
" Author:        Travis Herrick
" Version:       0.1
" Description:   Open a spec/class based on the current file.

function af:OpenAlternate()
  let root = substitute(expand('%:h'), '/.*', '', '')

  if root == 'spec'
    execute af:OpenClass()
  else
    execute af:OpenSpec()
  endif
endfunction

function af:OpenSpec()
  let buffer = 'spec/' . expand('%:r') . '_spec.' . expand('%:e')
  execute 'vsplit ' . buffer
endfunction

function af:OpenClass()
  let buffer = expand('%')
  let buffer = substitute(buffer, '_spec\.', '.', '')
  let buffer = substitute(buffer, '^spec/', '', '')
  execute 'vsplit ' . buffer
endfunction
