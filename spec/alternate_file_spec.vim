let s:sid = g:alternate_file_sid
let s:line = 0
let s:logs = []

function! s:behave_like_is_folder(path, expected)
  let cmd = s:sid . "is_spec_folder('" . a:path . "')"

  execute 'let actual = ' . cmd

  call s:log('expected:' . a:expected)
  call s:log('actual: ' . actual)

  call s:assert(a:expected == actual, '')
endfunction

function! s:Test_is_spec_folder()
  call s:behave_like_is_folder('foo/bar/baz', 1)
endfunction

function! s:assert(value, message)
  let msg = a:message

  if msg == ''
    let msg = a:value . ' is not truthy.'
  endif

  AssertTxt(a:value, msg)
endfunction

function! s:Teardown()
  call s:write_log()
endfunction

function! s:write_log()
  new

  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted

  call setline(1, s:logs)

  w! >> spec.txt

  q
endfunction

function! s:log(message)
  call add(s:logs, a:message)
endfunction
