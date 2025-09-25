# Fallbacks pessoais (usados se o pywal não tiver carregado)
set -g POWERLINE_SEP '→'
set -g GM_PRIMARY  "#F15BB5"
set -g GM_LIGHT    "#F0F0F0"
set -g GM_ACCENT   "#00BBF9"
set -g GM_ALT1     "#9B5DE5"
set -g GM_ALT2     "#00F5D4"

function __pick --description "Escolhe cor do wal ou fallback"
    set -l prefer $argv[1]
    set -l backup $argv[2]
    if test -n "$prefer"
        echo $prefer
    else
        echo $backup
    end
end

function fish_prompt
    set -l last_status $status

    # Tenta trazer paleta do pywal (caso o shell tenha iniciado sem carregar)
    if test -f ~/.cache/wal/colors.fish
        source ~/.cache/wal/colors.fish ^/dev/null
    end

    # Escolha de cores (prioriza wal; cai para tuas GM_* se não houver)
    set -l C_USER  (__pick $color4  $GM_ACCENT)
    set -l C_PATH  (__pick $color6  $GM_PRIMARY)
    set -l C_GIT   (__pick $color2  $GM_ALT1)
    set -l C_ERR   (__pick $color1  $GM_ALT2)
    set -l C_SYM   (__pick $foreground $GM_LIGHT)

    # user
    set_color $C_USER
    printf '%s ' (whoami)

    # path
    set_color $C_PATH
    printf '%s ' (prompt_pwd)

    # separador
    set_color $C_SYM
    printf '%s ' $POWERLINE_SEP

    # git
    if git rev-parse --is-inside-work-tree &>/dev/null
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
        set_color $C_GIT
        printf 'git:%s ' $branch
        if not git diff --quiet &>/dev/null
            printf '* '
        end
    end

    # status anterior
    if test $last_status -ne 0
        set_color $C_ERR
        printf 'status:%d ' $last_status
    end

    set_color normal
end

function fish_right_prompt
    # Paleta do lado direito
    if test -f ~/.cache/wal/colors.fish
        source ~/.cache/wal/colors.fish ^/dev/null
    end
    set -l C_RIGHT (__pick $color8 $GM_LIGHT)

    set_color $C_RIGHT
    printf '%s' (date '+%H:%M')

    if set -q BATTERY_PERCENT; and test $BATTERY_PERCENT -le 100
        printf ' %d%%' $BATTERY_PERCENT
    end
    set_color normal
end

