set guicursor=a:blinkwait1600-blinkon1600-blinkoff800
set guioptions=

if has('gui_macvim')
  let macvim_hig_shift_movement = 1
  set guifont=TriplicateT4c:h15
  set linespace=-1
  set macmeta
endif

colorscheme plan9
