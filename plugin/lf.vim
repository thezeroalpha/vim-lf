if exists('g:loaded_lf') || &cp || (v:version < 802 && ! has('nvim'))
  finish
endif
let g:loaded_lf = 1

let s:cpo_save = &cpo
set cpo&vim

command! -nargs=+ LF call lf#LF(<f-args>, [])
nnoremap <Plug>LfEdit :LF %:p edit<CR>
nnoremap <Plug>LfSplit :LF %:p split<CR>

let &cpo = s:cpo_save
unlet s:cpo_save
