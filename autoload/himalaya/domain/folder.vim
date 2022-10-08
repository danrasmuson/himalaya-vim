" Represents the current page being displayed.
let s:page = 1

function! himalaya#domain#folder#current_page() abort
  return s:page
endfunction

function! himalaya#domain#folder#select_previous_page() abort
  let s:page = max([1, s:page - 1])
  call himalaya#email#list()
endfunction

function! himalaya#domain#folder#select_next_page() abort
  let s:page = s:page + 1
  call himalaya#email#list()
endfunction

" Represents the current folder being selected.
let s:folder = 'INBOX'

function! himalaya#domain#folder#current() abort
  return s:folder
endfunction

function! himalaya#domain#folder#open_picker(callback) abort
  try
    let account = himalaya#domain#account#current()
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

    execute printf('call himalaya#domain#folder#pickers#%s#select(a:callback, folders)', picker)
  catch
    if !empty(v:exception)
      redraw
      call himalaya#log#err(v:exception)
    endif
  endtry
endfunction

function! himalaya#domain#folder#select() abort
  call himalaya#domain#folder#open_picker('himalaya#domain#folder#handle_select')
endfunction

function! himalaya#domain#folder#handle_select(folder) abort
  let s:folder = a:folder
  let s:page = 1
  call himalaya#domain#email#list()
endfunction
