function s:luafn(mod, f, arg)
   return luaeval('require("' . a:mod . '")["' . a:f . '"](...)', a:arg)
endfunction

function! asyncomplete#sources#conjure#completor(opt, ctx)
   let l:col = a:ctx['col']
   let l:typed = a:ctx['typed']
   let l:kw = matchstr(l:typed, '\k\+')
   let l:kwlen = len(l:kw)

   let l:context = {
            \ 'name': a:opt['name'],
            \ 'ctx': a:ctx,
            \ 'startcol': l:col - l:kwlen,
            \ 'prom': s:luafn('conjure.eval', 'completions-promise', l:kw)
            \}

   function! context.callback(timer)
      if s:luafn('conjure.promise', 'done?', self.prom)
         call timer_stop(a:timer)
         call asyncomplete#complete(self.name, self.ctx, self.startcol,
                  \ s:luafn('conjure.promise', 'close', self.prom))
      endif
   endfunction

   call timer_start(20, context.callback, {'repeat': -1})
endfunction

function! asyncomplete#sources#conjure#get_source_options(opts)
   return a:opts
endfunction
