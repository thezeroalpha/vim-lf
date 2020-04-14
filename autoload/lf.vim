function! lf#LF(path, edit_cmd)
  let oldguioptions = &guioptions
  let s:oldlaststatus = &laststatus
  let s:choice_file_path = tempname()
  let s:edit_cmd = a:edit_cmd
  try
    if has('nvim')
      set laststatus=0
      let currentPath = expand(a:path)
      let lfCallback = { 'name': 'lf', 'edit_cmd': a:edit_cmd }
      function! lfCallback.on_exit(job_id, code, event)
        if a:code == 0
          if exists(":Bclose")
            silent! Bclose!
          else
            echoerr "Failed to close buffer, make sure the `rbgrouleff/bclose.vim` plugin is installed"
          endif
        endif
        try
          if filereadable(s:choice_file_path)
            for f in readfile(s:choice_file_path)
              exec self.edit_cmd . f
            endfor
            call delete(s:choice_file_path)
          endif
        endtry
        let &laststatus=s:oldlaststatus
      endfunction
      enew
      call termopen('lf -selection-path=' . s:choice_file_path . ' "' . currentPath . '"', lfCallback)
      startinsert
    else
      function! s:EditCallback()
        if filereadable(s:choice_file_path)
          for f in readfile(s:choice_file_path)
            exec s:edit_cmd . f
          endfor
          call delete(s:choice_file_path)
        endif
        redraw!
        " reset the filetype to fix the issue that happens
        " when opening lf on VimEnter (with `vim .`)
        filetype detect
      endfunction
      set guioptions+=! " Make it work with MacVim
      let currentPath = expand(a:path)
      let buf = term_start(["lf", '-selection-path='.s:choice_file_path, '"'.currentPath.'"'], #{hidden: 1, term_finish: 'close'})
      let winid = popup_dialog(buf, #{minwidth: 150, minheight: 20, highlight: 'Normal'})
      let bufn = winbufnr(winid)
      exe 'autocmd! BufWinLeave <buffer='.bufn.'> call s:EditCallback()'
    endif
  endtry
  let &guioptions=oldguioptions
endfunction
