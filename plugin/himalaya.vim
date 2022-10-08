if exists('g:himalaya_loaded')
  finish
endif

if !executable('himalaya')
  throw 'Himalaya CLI not found, see https://github.com/soywod/himalaya#installation'
endif

" Backup cpo
let s:cpo_backup = &cpo
set cpo&vim

command! -nargs=* Himalaya             call himalaya#domain#email#list(<f-args>)
command! -nargs=* HimalayaMove         call himalaya#domain#email#move()
command! -nargs=* HimalayaCopy         call himalaya#domain#email#copy()
command! -nargs=* HimalayaDelete       call himalaya#domain#email#delete()
command! -nargs=* HimalayaWrite        call himalaya#domain#email#write()
command! -nargs=* HimalayaReply        call himalaya#domain#email#reply()
command! -nargs=* HimalayaReplyAll     call himalaya#domain#email#reply_all()
command! -nargs=* HimalayaForward      call himalaya#domain#email#forward()
command! -nargs=* HimalayaFolders      call himalaya#domain#folder#select()
command! -nargs=1 HimalayaFolder       call himalaya#domain#folder#handle_select(<f-args>)
command! -nargs=* HimalayaNextPage     call himalaya#domain#folder#select_next_page()
command! -nargs=* HimalayaPreviousPage call himalaya#domain#folder#select_previous_page()
command! -nargs=* HimalayaAttach       call himalaya#domain#email#add_attachment()
command! -nargs=* HimalayaAttachments  call himalaya#domain#email#attachments()

" Restore cpo
let &cpo = s:cpo_backup
unlet s:cpo_backup

let g:himalaya_loaded = 1
