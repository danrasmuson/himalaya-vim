" Represents the folder picker based the standard `input` vim
" function.
function! s:native_picker(callback, folders)
  let folders = map(copy(a:folders), 'printf("%s (%d)", v:val.name, v:key)')
  
  let folder_index = input(join(folders, ', ') . ': ')
  if folder_index == ''
    throw 'Action aborted'
  endif
  
  redraw | echo
  call function(a:callback)(a:folders[folder_index].name)
endfunction

" Represents the folder picker based on [fzf] and [fzf.vim]. Both need
" to be installed to use this picker.
"
" [fzf]: https://github.com/junegunn/fzf
" [fzf.vim]: https://github.com/junegunn/fzf.vim
function! s:fzf_picker(callback, folders)
  call fzf#run({
  \ 'source': map(a:folders, 'v:val.name'),
  \ 'sink': function(a:callback),
  \ 'down': '25%',
  \})
endfunction

" Represents the folder picker based on [telescope.nvim]. The plugin
" needs to be installed in order to use this picker. Works only on
" Neovim.
"
" [telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
function! s:telescope_picker(callback, folders)
  call luaeval('require("himalaya.mbox").mbox_picker')(a:callback, a:folders)
endfunction

let s:curr_page = 1
let s:curr_folder = 'INBOX'

function! himalaya#mbox#curr_page()
  return s:curr_page
endfunction

function! himalaya#mbox#curr_mbox()
  return s:curr_folder
endfunction

function! himalaya#mbox#prev_page()
  let s:curr_page = max([1, s:curr_page - 1])
  call himalaya#msg#list()
endfunction

function! himalaya#mbox#next_page()
  let s:curr_page = s:curr_page + 1
  call himalaya#msg#list()
endfunction

function! himalaya#mbox#pick(cb)
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

    execute printf('call s:%s_picker(a:cb, folders)', picker)
  catch
    if !empty(v:exception)
      redraw | call himalaya#shared#log#err(v:exception)
    endif
  endtry
endfunction

function! himalaya#mbox#change()
  call himalaya#mbox#pick('himalaya#mbox#_change')
endfunction

function! himalaya#mbox#_change(mbox)
  let s:curr_folder = a:mbox
  let s:curr_page = 1
  call himalaya#msg#list()
endfunction
