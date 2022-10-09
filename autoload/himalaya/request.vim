function! s:request(type, opts) abort
  let msg = get(a:opts, 'msg', '')
  let cmd = get(a:opts, 'cmd', '')
  let args = get(a:opts, 'args', [])
  let should_throw = get(a:, 'opts.should_throw', v:false)

  call himalaya#log#info(printf('%s…', msg))
  let cmd = call('printf', ['himalaya --output %s ' . cmd, a:type] + args)
  let res = system(cmd)

  if empty(res)
    redraw | call himalaya#log#info(printf('%s [OK]', msg))
  else
    try
      redraw | call himalaya#log#info(printf('%s [OK]', msg))
      if a:type == 'json'
        let res = substitute(res, ':null', ':v:null', 'g')
        let res = substitute(res, ':true', ':v:true', 'g')
        let res = substitute(res, ':false', ':v:false', 'g')
        let res = eval(res)
        return res
      else
        return trim(res)
      endif
      redraw | call himalaya#log#info(printf('%s [OK]', msg))
    catch
      redraw
      for line in split(res, "\n")
        call himalaya#log#err(line)
      endfor
      if should_throw
        throw ''
      endif
    endtry
  endif
endfunction

function! himalaya#request#json(opts) abort
  return s:request('json', a:opts)
endfunction

function! himalaya#request#plain(opts) abort
  return s:request('plain', a:opts)
endfunction
