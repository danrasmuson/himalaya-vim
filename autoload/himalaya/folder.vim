" Represents the current page being displayed.
let s:curr_page = 1

function! himalaya#folder#curr_page() abort
  return s:curr_page
endfunction

function! himalaya#folder#prev_page() abort
  let s:curr_page = max([1, s:curr_page - 1])
  call himalaya#msg#list()
endfunction

function! himalaya#folder#next_page() abort
  let s:curr_page = s:curr_page + 1
  call himalaya#msg#list()
endfunction

" Represents the current folder being selected.
let s:curr_folder = 'INBOX'

function! himalaya#folder#curr_folder() abort
  return s:curr_folder
endfunction

function! himalaya#folder#open_picker(callback) abort
  try
    let account = himalaya#account#curr()
    let folders = himalaya#request#json({
    \ 'cmd': '--account %s folders',
    \ 'args': [shellescape(account)],
    \ 'msg': 'Fetching folders',
    \ 'should_throw': 0,
    \})

    if exists('g:himalaya_mailbox_picker')
      let picker = g:himalaya_mailbox_picker
    else
      if &rtp =~ 'telescope'
        let picker = 'telescope'
      elseif &rtp =~ 'fzf'
        let picker = 'fzf'
      else
        let picker = 'native'
      endif
    endif

    execute printf('call himalaya#folder#pickers#%s#select(a:callback, folders)', picker)
  catch
    if !empty(v:exception)
      redraw | call himalaya#shared#log#err(v:exception)
    endif
  endtry
endfunction

function! himalaya#folder#select() abort
  call himalaya#folder#open_picker('himalaya#folder#handle_select')
endfunction

function! himalaya#folder#handle_select(folder) abort
  let s:curr_folder = a:folder
  let s:curr_page = 1
  call himalaya#msg#list()
endfunction
