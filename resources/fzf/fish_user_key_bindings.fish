function fish_user_key_bindings
    fzf_key_bindings
end
set -U FZF_DEFAULT_OPTS '--height 99% --layout=reverse --bind=ctrl-l:preview-page-down,ctrl-h:preview-page-up'
set -U FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow -E ".ssh" -E ".cache" -E ".local" -E ".npm" -E ".git" -E "node_modules" . /home '
set -U FZF_ALT_C_COMMAND 'fd --type d --hidden --follow -E ".git" -E "node_modules" . /home '
