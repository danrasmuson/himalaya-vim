" Represents the current email id being selected.
let s:id = ''

" Represents the current draft (useful during edition).
let s:draft = ''

" Represents the current attachment paths (useful during edition).
let s:attachment_paths = []

let s:pos = []

" Listing

function! himalaya#domain#email#list(...) abort
  if a:0 > 0
    call himalaya#domain#account#select(a:1)
  endif
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  let page = himalaya#domain#folder#current_page()
  call himalaya#domain#email#list_with(account, folder, page)
endfunction

function! himalaya#domain#email#list_with(account, folder, page) abort
  let s:pos = getpos('.')
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s list --max-width %d --page %d',
  \ 'args': [shellescape(a:account), shellescape(a:folder), s:bufwidth(), a:page],
  \ 'msg': printf('Fetching %s emails', a:folder),
  \ 'on_data': {data -> s:list_with(a:folder, a:page, data)}
  \})
endfunction

function! s:list_with(folder, page, emails) abort
  let buftype = stridx(bufname('%'), 'Himalaya emails') == 0 ? 'file' : 'edit'
  execute printf('silent! %s Himalaya emails [%s] [page %d]', buftype, a:folder, a:page)
  setlocal modifiable
  silent execute '%d'
  call append(0, split(a:emails, "\n"))
  silent execute '$d'
  setlocal filetype=himalaya-email-listing
  let &modified = 0
  execute 0
  call setpos('.', s:pos)
endfunction

" Reading

function! himalaya#domain#email#read() abort
  let s:id = s:get_email_id_under_cursor()
  if empty(s:id) || s:id == 'ID'
    return
  endif
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s read %s',
  \ 'args': [shellescape(account), shellescape(folder), s:id],
  \ 'msg': printf('Fetching email %s', s:id),
  \ 'on_data': {data -> s:read(s:id, data)},
  \})
endfunction

function! s:read(id, email)
  call s:close_open_buffers('Himalaya read email')
  execute printf('silent! botright new Himalaya read email [%s]', a:id)
  setlocal modifiable
  silent execute '%d'
  call append(0, split(substitute(a:email, "\r", '', 'g'), "\n"))
  silent execute '$d'
  setlocal filetype=himalaya-email-reading
  let &modified = 0
  execute 0
endfunction

" Writing

function! himalaya#domain#email#write(...) abort
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  if a:0 > 0
    call s:write(a:1)
  else
    call himalaya#request#plain({
    \ 'cmd': '--account %s --folder %s template new',
    \ 'args': [shellescape(account), shellescape(folder)],
    \ 'msg': 'Fetching new template',
    \ 'on_data': {data -> s:write('write', data)},
    \})
  endif
endfunction

function! himalaya#domain#email#reply() abort
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  let id = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursor() : s:id
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s template reply %s',
  \ 'args': [shellescape(account), shellescape(folder), id],
  \ 'msg': 'Fetching reply template',
  \ 'on_data': {data -> s:write(printf('reply [%s]', id), data)},
  \})
endfunction

function! himalaya#domain#email#reply_all() abort
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  let id = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursor() : s:id
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s template reply %s --all',
  \ 'args': [shellescape(account), shellescape(folder), id],
  \ 'msg': 'Fetching reply all template',
  \ 'on_data': {data -> s:write(printf('reply all [%s]', id), data)},
  \})
endfunction

function! himalaya#domain#email#forward() abort
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  let id = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursor() : s:id
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s template forward %s',
  \ 'args': [shellescape(account), shellescape(folder), id],
  \ 'msg': 'Fetching forward template',
  \ 'on_data': {data -> s:write(printf('forward [%s]', id), data)},
  \})
endfunction

function! s:write(msg, email) abort
  let bufname = printf('Himalaya %s', a:msg)
  if a:msg == 'write'
    execute printf('silent! botright new %s', bufname)
  endif
  execute printf('silent! edit %s', bufname)
  setlocal modifiable
  silent execute '%d'
  call append(0, split(substitute(a:email, "\r", '', 'g'), "\n"))
  silent execute '$d'
  setlocal filetype=himalaya-email-writing
  let &modified = 0
  execute 0
endfunction

" Manipulating

function! himalaya#domain#email#select_folder_then_copy() abort
  call himalaya#domain#folder#open_picker('himalaya#domain#email#copy')
endfunction

function! himalaya#domain#email#copy(folder) abort
  let id = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursor() : s:id
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s copy %s %s',
  \ 'args': [shellescape(account), shellescape(folder), id, shellescape(a:folder)],
  \ 'msg': 'Copying email',
  \ 'on_data': {-> himalaya#domain#email#list_with(account, folder, himalaya#domain#folder#current_page())},
  \})
endfunction

function! himalaya#domain#email#select_folder_then_move() abort
  call himalaya#domain#folder#open_picker('himalaya#domain#email#move')
endfunction

function! himalaya#domain#email#move(folder) abort
  let id = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursor() : s:id
  let choice = input(printf('Are you sure you want to move the email %s? (y/N) ', id))
  redraw | echo
  if choice != 'y' | return | endif
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s move %s %s',
  \ 'args': [shellescape(account), shellescape(folder), id, shellescape(a:folder)],
  \ 'msg': 'Moving email',
  \ 'on_data': {-> himalaya#domain#email#list_with(account, folder, himalaya#domain#folder#current_page())},
  \})
endfunction

function! himalaya#domain#email#delete() abort range
  let ids = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursors(a:firstline, a:lastline) : s:id
  let choice = input(printf('Are you sure you want to delete email(s) %s? (y/N) ', ids))
  redraw | echo
  if choice != 'y' | return | endif
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s delete %s',
  \ 'args': [shellescape(account), shellescape(folder), ids],
  \ 'msg': 'Deleting email',
  \ 'on_data': {-> himalaya#domain#email#list_with(account, folder, himalaya#domain#folder#current_page())},
  \})
endfunction

" Other

function! himalaya#domain#email#save_draft() abort
  let s:draft = join(getline(1, '$'), "\n") . "\n"
  redraw
  call himalaya#log#info('Save draft [OK]')
  let &modified = 0
endfunction

function! himalaya#domain#email#process_draft() abort
  try
    let account = himalaya#domain#account#current()
    let attachments = join(map(s:attachment_paths, '"--attachment ".v:val'), ' ')
    while 1
      let choice = input('(s)end, (d)raft, (q)uit or (c)ancel? ')
      let choice = tolower(choice)[0]
      redraw | echo

      if choice == 's'
        return himalaya#request#plain({
        \ 'cmd': '--account %s template send %s -- %s',
        \ 'args': [shellescape(account), attachments, shellescape(s:draft)],
        \ 'msg': 'Sending email',
        \ 'on_data': {-> {}},
        \})
      elseif choice == 'd'
        return himalaya#request#plain({
        \ 'cmd': '--account %s --folder drafts save %s -- %s',
        \ 'args': [shellescape(account), attachments, shellescape(s:draft)],
        \ 'msg': 'Saving draft',
        \ 'on_data': {-> {}},
        \})
      elseif choice == 'q'
        return
      elseif choice == 'c'
        call himalaya#domain#email#write(join(getline(1, '$'), "\n") . "\n")
        return
      endif
    endwhile
  catch
    call himalaya#log#err(v:exception)
    throw ''
  endtry
endfunction

function! himalaya#domain#email#attachments() abort
  let account = himalaya#domain#account#current()
  let folder = himalaya#domain#folder#current()
  let id = stridx(bufname('%'), 'Himalaya emails') == 0 ? s:get_email_id_under_cursor() : s:id
  call himalaya#request#plain({
  \ 'cmd': '--account %s --folder %s attachments %s',
  \ 'args': [shellescape(account), shellescape(folder), id],
  \ 'msg': 'Downloading attachments',
  \ 'on_data': {data -> himalaya#log#info(data)},
  \})
endfunction

function! himalaya#domain#email#complete_contact(findstart, base) abort
  try
    if a:findstart
      if !exists('g:himalaya_complete_contact_cmd')
        echoerr 'You must set "g:himalaya_complete_contact_cmd" to complete contacts'
        return -3
      endif

      " search for everything up to the last colon or comma
      let line_to_cursor = getline('.')[:col('.') - 1]
      let start = match(line_to_cursor, '[^:,]*$')

      " don't include leading spaces
      while start <= len(line_to_cursor) && line_to_cursor[start] == ' '
        let start += 1
      endwhile

      return start
    else
      let output = system(substitute(g:himalaya_complete_contact_cmd, '%s', a:base, ''))
      let lines = split(output, "\n")

      return map(lines, 's:line_to_complete_item(v:val)')
    endif
  catch
    if !empty(v:exception)
      redraw
      call himalaya#log#err(v:exception)
    endif
  endtry
endfunction

function! himalaya#domain#email#add_attachment() abort
  try
    let attachment_path = input('Attachment path: ', '', 'file')
    if empty(expand(glob(attachment_path)))
      throw 'The file does not exist'
    endif
    call add(s:attachment_paths, attachment_path)
    redraw
    call himalaya#log#info('Attachment added!')
  catch
    if !empty(v:exception)
      redraw
      call himalaya#log#err(v:exception)
    endif
  endtry
endfunction

" https://newbedev.com/get-usable-window-width-in-vim-script
function! s:bufwidth() abort
  let width = winwidth(0)
  let numberwidth = max([&numberwidth, strlen(line('$'))+1])
  let numwidth = (&number || &relativenumber)? numberwidth : 0
  let foldwidth = &foldcolumn

  if &signcolumn == 'yes'
    let signwidth = 2
  elseif &signcolumn == 'auto'
    let signs = execute(printf('sign place buffer=%d', bufnr('')))
    let signs = split(signs, "\n")
    let signwidth = len(signs)>2? 2: 0
  else
    let signwidth = 0
  endif
  return width - numwidth - foldwidth - signwidth
endfunction

function! s:get_email_id_from_line(line) abort
  return matchstr(a:line, '[0-9a-zA-Z]*')
endfunction

function! s:get_email_id_under_cursor() abort
  try
    return s:get_email_id_from_line(getline('.'))
  catch
    throw 'email not found'
  endtry
endfunction

function! s:get_email_id_under_cursors(from, to) abort
  try
    return join(map(range(a:from, a:to), 's:get_email_id_from_line(getline(v:val))'), ',')
  catch
    throw 'emails not found'
  endtry
endfunction

function! s:close_open_buffers(name) abort
  let open_buffers = filter(range(1, bufnr('$')), 'bufexists(v:val)')
  let target_buffers = filter(open_buffers, 'buffer_name(v:val) =~ a:name')
  for buffer_to_close in target_buffers
    execute ':bwipeout ' . buffer_to_close
  endfor
endfunction

function! s:line_to_complete_item(line) abort
  let fields = split(a:line, '\t')
  let email = fields[0]
  let name = ''
  if len(fields) > 1
    let name = printf('"%s"', fields[1])
  endif

  return name . printf('<%s>', email)
endfunction
