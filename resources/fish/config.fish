#启动vi命令行模式
fish_vi_key_bindings

set -g fish_cursor_default block
set -g fish_cursor_insert  line
set -g fish_cursor_visual  underscore

#如果发现 vi 模式下， fish 的自动补全快捷键 control + f 不能用了，可在配置文件中添加如下脚本来修复这个快捷键：
for mode in insert default visual
    bind --user -M $mode \cf forward-char
end


bind --user yy fish_clipboard_copy

bind -s --user -M visual -m default y "commandline -s | xsel --input --clipboard; commandline -f end-selection repaint-mode"

bind -s --user -M default P "commandline -i -- (xsel --output --clipboard; echo)[1];"\
			    "commandline -f backward-char repaint;"
function M_default_p
	if [ -z (xsel --output --clipboard) ]
		return
	end
	set -l pre_part (string sub --length (math (commandline -C) + 1) -- (commandline -b))
	set -l last_part (string sub --start (math (commandline -C) + 2) -- (commandline -b))
	commandline -r -- $pre_part(xsel --output --clipboard)$last_part
	__set_cursor_pos (math (string length -- $pre_part) + (string length -- (xsel --output --clipboard)) - 1)
	commandline -f repaint
end
bind -s --user -M default p M_default_p

function __set_cursor_pos
    eval "commandline -f beginning-of-line "\
	(string repeat -n $argv[1] ' forward-char')
end

function M_visual_m_default_p
	set -l e_pos (math -(string length -- (commandline -s)) + 1)
	set -l pre_part
	if string match '*'(string sub -e -1 -- (commandline -s)) -- (commandline -c) >/dev/null 2>&1
		if test $e_pos -eq 0
				set pre_part (string sub -- (commandline -c))
		else
				set pre_part (string sub -e $e_pos -- (commandline -c))
		end
	else
		if test (string length -- (commandline -c)) -eq (string length -- (commandline))
			set pre_part (string sub -e -(string length -- (commandline -s)) -- (commandline -c))
		else
			set pre_part (commandline -c)
		end
	end
	set -l last_part (string sub -s (math (string length -- $pre_part) + (string length -- (commandline -s)) + 1) -- (commandline -b))
	commandline -r -- $pre_part(xsel --output --clipboard)$last_part
	__set_cursor_pos (math (string length -- $pre_part) + (string length -- (xsel --output --clipboard)) - 1)
	commandline -f end-selection repaint-mode
end
bind -s --user -M visual -m default p M_visual_m_default_p



bind -s --user -M visual -m default s "commandline -s | xsel --input --clipboard;"\
				      "commandline -f kill-selection end-selection repaint-mode"

bind -s --user -M default -m visual viw begin-selection forward-char backward-word swap-selection-start-stop forward-word backward-char repaint-mode
bind -s --user -M default -m visual viW begin-selection forward-char backward-bigword swap-selection-start-stop forward-bigword backward-char repaint-mode
bind -s --user -M default -m visual vi backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump swap-selection-start-stop  repaint-mode
bind -s --user -M default -m visual va backward-jump and repeat-jump-reverse and begin-selection repeat-jump swap-selection-start-stop repaint-mode
bind -s --user -M default -m visual V begin-selection beginning-of-line swap-selection-start-stop end-of-line backward-char repaint-mode

bind -s --user u undo
bind -s --user U redo



