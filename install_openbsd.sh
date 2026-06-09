#!/bin/sh

wscons() (
	conf=/etc/wsconsctl.conf
	for line in mouse.tp.tapping=0 mouse.reverse_scrolling=1; do
		doas grep -qxF "$line" "$conf" 2>/dev/null || {
			echo "$line" | doas tee -a "$conf" >/dev/null
			log "$conf: added $line"
		}
		doas wsconsctl "$line" >/dev/null
	done
)

tmux_xsel() (
	tcl="$HOME/.tmux.conf.local"
	command -v xsel >/dev/null 2>&1 || log 'xsel missing; tmux clipboard copy disabled (pkg_add xsel)'
	grep -qF "copy-pipe 'xsel -ib'" "$tcl" 2>/dev/null && return
	cat >>"$tcl" <<-'EOF'
	# OpenBSD xterm lacks OSC 52; copy through xsel.
	bind -T copy-mode-vi y send-keys -X copy-pipe 'xsel -ib'
	bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe 'xsel -ib'
	bind -T copy-mode-vi DoubleClick1Pane select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe 'xsel -ib'
	bind -T copy-mode-vi TripleClick1Pane select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe 'xsel -ib'
	EOF
	log "$tcl: added xsel copy bindings"
)

cursor() (
	mkdir -p "$HOME/.icons/default"
	cat >"$HOME/.icons/default/index.theme" <<-'EOF'
	[Icon Theme]
	Inherits=Adwaita
	EOF
	mkdir -p "$HOME/.config/gtk-3.0"
	grep -q gtk-cursor-theme-size "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null && return
	cat >>"$HOME/.config/gtk-3.0/settings.ini" <<-'EOF'
	[Settings]
	gtk-cursor-theme-name=Adwaita
	gtk-cursor-theme-size=32
	EOF
)

wallpaper() (
	pic=/usr/local/share/openbsd-backgrounds/landscape/deraadt/limestone-0728-073918tdr.jpg
	command -v xwallpaper >/dev/null 2>&1 && [ -f "$pic" ] && return
	log 'wallpaper packages missing (pkg_add xwallpaper openbsd-backgrounds)'
)

vim_openbsd() (
	fileline '^set rtp\+=/usr/local/share/vim/vimfiles' 'set rtp+=/usr/local/share/vim/vimfiles' "$HOME/.vimrc.local"
	grep -qF 'xsel -ib' "$HOME/.vimrc.local" 2>/dev/null && return
	cat >>"$HOME/.vimrc.local" <<-'EOF'
	" OpenBSD xterm lacks OSC 52; copy yanks through xsel.
	if executable('xsel')
	autocmd! dotfiles TextYankPost
	autocmd dotfiles TextYankPost * if v:event.operator ==# 'y' | call system('xsel -ib', getreg('"')) | endif
	nnoremap <silent> <leader>y <Cmd>call system('xsel -ib', fnamemodify(expand('%:p'), ':.'))<CR>
	nnoremap <silent> <leader>Y <Cmd>call system('xsel -ib', expand('%:p'))<CR>
	endif
	EOF
)

wscons
tmux_xsel
cursor
wallpaper
vim_openbsd
