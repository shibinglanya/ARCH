function fzf-bcd-widget -d 'cd backwards'
        pwd | awk -v RS=/ '/\n/ {exit} {p=p $0 "/"; print p}' | tac | eval (__fzfcmd) +m --select-1 --exit-0 $FZF_BCD_OPTS | read -l result
        [ "$result" ]; and cd $result
        commandline -f repaint
end

function fzf-select -d 'fzf commandline job and print unescaped selection back to commandline'
        set -l cmd (commandline -j)
        [ "$cmd" ]; or return
        eval $cmd | eval (__fzfcmd) -m --tiebreak=index --select-1 --exit-0 | string join ' ' | read -l result
        [ "$result" ]; and commandline -j -- $result
        commandline -f repaint
end

function fzf-complete -d 'fzf completion and print selection back to commandline'
        # As of 2.6, fish's "complete" function does not understand
        # subcommands. Instead, we use the same hack as __fish_complete_subcommand and
        # extract the subcommand manually.
        set -l cmd (commandline -co) (commandline -ct)
        switch $cmd[1]
            case env sudo
                for i in (seq 2 (count $cmd))
                    switch $cmd[$i]
                        case '-*'
                        case '*=*'
                        case '*'
                            set cmd $cmd[$i..-1]
                            break
                    end
                end
        end
        set cmd (string join -- ' ' $cmd)

        set -l complist (complete -C$cmd)
        set -l result
        string join -- \n $complist | sort | eval (__fzfcmd) -m --select-1 --exit-0 --header '(commandline)' | cut -f1 | while read -l r; set result $result $r; end

        set prefix (string sub -s 1 -l 1 -- (commandline -t))
        for i in (seq (count $result))
            set -l r $result[$i]
            switch $prefix
                case "'"
                    commandline -t -- (string escape -- $r)
                case '"'
                    if string match '*"*' -- $r >/dev/null
                        commandline -t --  (string escape -- $r)
                    else
                        commandline -t -- '"'$r'"'
                    end
                case '~'
                    commandline -t -- (string sub -s 2 (string escape -n -- $r))
                case '*'
                    commandline -t -- (string escape -n -- $r)
            end
            [ $i -lt (count $result) ]; and commandline -i ' '
        end

        commandline -f repaint
end

function fco -d "Fuzzy-find and checkout a branch"
      git branch --all | grep -v HEAD | string trim | fzf | read -l result; and git checkout "$result"
end

function fcoc -d "Fuzzy-find and checkout a commit"
      git log --pretty=oneline --abbrev-commit --reverse | fzf --tac +s -e | awk '{print $1;}' | read -l result; and git checkout "$result"
end

function fssh -d "Fuzzy-find ssh host via ag and ssh into it"
      ag --ignore-case '^host [^*]' ~/.ssh/config | cut -d ' ' -f 2 | fzf | read -l result; and ssh "$result"
end

function fs -d "Switch tmux session"
      tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux switch-client -t "$result"
end

function fpass -d "Fuzzy-find a Lastpass entry and copy the password"
      if not lpass status -q
        lpass login $EMAIL
      end

      if not lpass status -q
        exit
      end

      lpass ls | fzf | string replace -r -a '.+\[id: (\d+)\]' '$1' | read -l result; and lpass show -c --password "$result"
end

function pathclean --description "Clean up PATH variable"
        set PATH (printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
end
