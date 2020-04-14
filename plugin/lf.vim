if exists('g:loaded_lf') || &cp
  finish
endif
let g:loaded_lf = 1

command! -nargs=+ LF call lf#LF(<f-args>)
nnoremap <Plug>LfEdit :LF % edit<CR>
nnoremap <Plug>LfSplit :LF % split<CR>

let &cpo = s:cpo_save
unlet s:cpo_save
