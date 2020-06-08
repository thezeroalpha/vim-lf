if exists('g:loaded_lf_autoload')
  finish
endif
let g:loaded_lf_autoload = 1

function! lf#LF(path, edit_cmd)
  let oldguioptions = &guioptions
  let s:oldlaststatus = &laststatus
  let s:choice_file_path = tempname()
  let s:mostLFArgs = 'lf -selection-path=' . s:choice_file_path . ' '
  " TODO: Test if currentPath needs shell quoting...
  let currentPath = expand(a:path)
  if has('nvim')
    " For internal usage - not needed by the API
    let termopen_opts = { 'edit_cmd': a:edit_cmd }
    function! termopen_opts.on_exit(job_id, code, event)
      if filereadable(s:choice_file_path)
        for f in readfile(s:choice_file_path)
          exec self.edit_cmd . ' ' . f
        endfor
        call delete(s:choice_file_path)
      endif
      if a:code == 0
        if exists(":Bclose")
          silent! Bclose! #
        elseif exists(":Bdelete")
          silent! Bdelete! #
        else
          let v:errmsg = "lf.vim: Failed to close buffer lf buffer -" .
                  \ "No `:Bdelete` or `:Bclose` commands were found. You can implement either of them yourself, or install either of:\n" .
                  \ " - https://github.com/rbgrouleff/bclose.vim\n" .
                  \ " - https://github.com/moll/vim-bbye"
          echo v:errmsg
        endif
      endif
    endfunction
    enew
      " We want Lf to quit after it saves the selections
      call termopen(s:mostLFArgs . '-command "map <right> push :open<enter>:quit<enter>" "' . currentPath . '"', termopen_opts)
    startinsert
  else
    let s:edit_cmd = a:edit_cmd
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
      " filetype detect
    endfunction
    set guioptions+=! " Make it work with MacVim
    let buf = term_start(s:mostLFArgs . currentPath . '"', #{hidden: 1, term_finish: 'close'})
    let winid = popup_dialog(buf, #{minwidth: 150, minheight: 20, highlight: 'Normal'})
    let bufn = winbufnr(winid)
    exe 'autocmd! BufWinLeave <buffer='.bufn.'> call s:EditCallback()'
  endif
  let &guioptions=oldguioptions
endfunction
