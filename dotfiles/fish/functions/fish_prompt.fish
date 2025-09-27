# ==============================
#  Fallbacks (se o pywal não carregar)
# ==============================
set -g POWERLINE_SEP '→'
set -g GM_PRIMARY  "#F15BB5"
set -g GM_LIGHT    "#F0F0F0"
set -g GM_ACCENT   "#00BBF9"
set -g GM_ALT1     "#9B5DE5"
set -g GM_ALT2     "#00F5D4"
set -g GM_BG       "#101010"
set -g GM_FG       "#d0d0d0"

# ==============================
#  Helpers
# ==============================
function __pick --description "Escolhe cor do wal ou fallback"
    set -l prefer $argv[1]
    set -l backup $argv[2]
    if test -n "$prefer"
        echo $prefer
    else
        echo $backup
    end
end

# remove "#": fish set_color aceita rrgabb sem cerquilha
function __hex
    if test (count $argv) -eq 0
        return
    end
    string replace -r '^#' '' -- $argv[1]
end

# Lê uma chave do ~/.cache/wal/colors.json e retorna "#rrggbb"
# Use SOMENTE a última parte da chave: background, foreground, color0..color15
function __wal --description "Lê chave do ~/.cache/wal/colors.json"
    set -l key $argv[1]
    set -l file ~/.cache/wal/colors.json
    if not test -f $file
        return
    end
    # Extrai o primeiro "#rrggbb" que aparecer na linha da chave
    set -l line (grep -oE "\"$key\" *: *\"#[0-9a-fA-F]{6}\"" $file | head -n1)
    if test -n "$line"
        string match -r '#[0-9a-fA-F]{6}' -- $line
    end
end

# ==============================
#  PROMPT ESQUERDO
# ==============================
function fish_prompt
    set -l last_status $status

    # === mapeia cores vindo do colors.json (com fallbacks) ===
    set -l C_BG   (__pick (__wal background) $GM_BG)
    set -l C_FG   (__pick (__wal foreground) $GM_FG)
    set -l C_USER (__pick (__wal color4)     $GM_ACCENT)   # azul/acent
    set -l C_PATH (__pick (__wal color2)     $GM_PRIMARY)  # verde/primária
    set -l C_GIT  (__pick (__wal color5)     $GM_ALT1)     # roxo/alt1
    set -l C_ERR  (__pick (__wal color1)     $GM_ALT2)     # vermelho/alt2
    set -l C_SYM  (__pick (__wal color7)     $GM_LIGHT)    # cinza claro

    # converte para formato aceito pelo fish (sem '#')
    set -l BX (__hex $C_BG)
    set -l FX (__hex $C_FG)
    set -l UX (__hex $C_USER)
    set -l PX (__hex $C_PATH)
    set -l GX (__hex $C_GIT)
    set -l EX (__hex $C_ERR)
    set -l SX (__hex $C_SYM)

    # ==== user ====
    set_color $UX
    printf '%s ' (whoami)

    # ==== path ====
    set_color $PX
    printf '%s ' (prompt_pwd)

    # ==== separador ====
    set_color $SX
    printf '%s ' $POWERLINE_SEP

    # ==== git (branch + dirty) ====
    if command -q git
        # estamos dentro de um repo?
        command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        if test $status -eq 0
            # branch (ou hash curto se detached)
            set -l branch (command git symbolic-ref -q --short HEAD)
            if test -z "$branch"
                set branch (command git rev-parse --short HEAD)
            end

            # sujo?
            set -l dirty ''
            command git diff --no-ext-diff --quiet --ignore-submodules -- >/dev/null 2>&1; or set dirty '*'

            set_color $GX
            printf 'git:%s%s ' $branch $dirty
        end
    end

    # ==== status anterior ====
    if test $last_status -ne 0
        set_color $EX
        printf 'status:%d ' $last_status
    end

    # símbolo de prompt
    set_color $SX
    printf '❯ '

    set_color normal
end

# ==============================
#  PROMPT DIREITO (hora + bateria opcional)
# ==============================
function fish_right_prompt
    set -l C_RIGHT (__pick (__wal color8) $GM_LIGHT)
    set -l RX (__hex $C_RIGHT)

    set_color $RX
    printf '%s' (date '+%H:%M')

    if set -q BATTERY_PERCENT; and test $BATTERY_PERCENT -le 100
        printf ' · %d%%' $BATTERY_PERCENT
    end
    set_color normal
end

