function! himalaya#request#json(opts) abort
  let args = get(a:opts, 'args', [])
  call himalaya#log#info(printf('%s…', a:opts.msg))
  let cmd = call('printf', [g:himalaya_executable . ' --output json ' . a:opts.cmd] + args)
  call himalaya#job#start(cmd, {data -> s:on_json_data(data, a:opts)})
endfunction

function! s:on_json_data(data, opts) abort
  call a:opts.on_data(json_decode(join(a:data)))
  redraw
  call himalaya#log#info(printf('%s [OK]', a:opts.msg))
endfunction

function! himalaya#request#plain(opts) abort
  call himalaya#log#info(printf('%s…', a:opts.msg))
  let cmd = call('printf', [g:himalaya_executable . ' --output plain ' . a:opts.cmd] + a:opts.args)
  call himalaya#job#start(cmd, {data -> s:on_plain_data(data, a:opts)})
endfunction

function! s:on_plain_data(data, opts) abort
  call a:opts.on_data(trim(a:data))
  redraw
  call himalaya#log#info(printf('%s [OK]', a:opts.msg))
endfunction
