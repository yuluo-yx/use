function fish_prompt
    set -l last_status $status
    set -l prompt_color 00FFAF
    set -l hash_color FF5FD7
    set -l identity_color 00D7FF
    set -l phrase_color FFD700
    set -l path_color 5FD7FF
    set -l git_color AF87FF
    set -l branch_color 87FF5F
    set -l time_color D7D7FF

    if test $last_status -ne 0
        set prompt_color FF5F5F
    end

    set_color --bold $hash_color
    echo -n '# '
    set_color --bold $identity_color
    echo -n 'shown@Mac-mini'
    set_color --bold $phrase_color
    echo -n ' Everything wins 🚀 '
    set_color $prompt_color
    echo -n 'in '
    set_color $path_color
    echo -n (pwd)

    # 仅在 git 仓库内显示分支；detached HEAD 时回退为短提交号。
    if command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
        set -l branch (command git branch --show-current 2>/dev/null)

        if test -z "$branch"
            set branch (command git rev-parse --short HEAD 2>/dev/null)
        end

        if test -n "$branch"
            set_color $git_color
            echo -n ' on git:['
            set_color --bold $branch_color
            echo -n $branch
            set_color $git_color
            echo -n ']'
        end
    end

    set_color $git_color
    echo -n ' ['
    set_color $time_color
    echo -n (date '+%H:%M:%S')
    set_color $git_color
    echo ']'
    set_color --bold $prompt_color
    echo -n '> '
    set_color normal
    return 0
end
