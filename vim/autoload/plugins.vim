vim9script

# Go loads vim-go with settings and buffer-local mappings.
export def Go()
	g:go_def_mode           = 'gopls'
	g:go_info_mode          = 'gopls'
	g:go_decls_mode         = 'fzf'
	g:go_term_close_on_exit = 0
	g:go_term_enabled       = 1
	g:go_term_mode          = 'split'
	g:go_term_reuse         = 1
	packadd vim-go
	augroup go_maps
		autocmd!
		autocmd FileType go nnoremap <buffer> <leader>c :GoCallers<CR>
		autocmd FileType go nnoremap <buffer> <leader>d :GoDeclsDir<CR>
		autocmd FileType go nnoremap <buffer> <leader>i :GoInfo<CR>
		autocmd FileType go nnoremap <buffer> <leader>t :GoTestFile -v<CR>
	augroup END
	doautocmd go_maps FileType
enddef
