command! -nargs=+ LF call lf#LF(<f-args>)
nnoremap <Plug>LfEdit :LF % edit<CR>
nnoremap <Plug>LfSplit :LF % split<CR>
