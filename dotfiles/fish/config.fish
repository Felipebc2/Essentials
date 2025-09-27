# ===================== PRESETS =====================

test -r ~/.cache/wal/colors.fish; source ~/.cache/wal/colors.fish

# Carrega paleta atual do pywal (se existir)
if test -r ~/.cache/wal/colors.fish
    source ~/.cache/wal/colors.fish
else if test -r ~/.cache/wal/sequences
    # fallback seguro (ainda aplica as cores no terminal)
    cat ~/.cache/wal/sequences
end


# ---- Tema do Fish baseado no pywal (com defaults se não houver wal) ----
# Se $foreground não existir, define cores padrão legíveis
if test -z "$foreground"
    set -g foreground "#c7c7c7"
    set -g background "#1e1e1e"
    set -g color0  "#1e1e1e"
    set -g color1  "#ff6b6b"
    set -g color2  "#8bd49c"
    set -g color3  "#ffd580"
    set -g color4  "#5ec4ff"
    set -g color5  "#c792ea"
    set -g color6  "#89ddff"
    set -g color7  "#eeeeee"
    set -g color8  "#777777"
    set -g color9  "#ff8787"
    set -g color10 "#a6e3b2"
    set -g color11 "#ffe0a3"
    set -g color12 "#8ad8ff"
    set -g color13 "#ddb6f2"
    set -g color14 "#b3eaff"
    set -g color15 "#ffffff"
end

# Mapeia as cores da interface do fish
set -g fish_color_normal         $foreground
set -g fish_color_command        $color4
set -g fish_color_param          $color6
set -g fish_color_quote          $color2
set -g fish_color_redirection    $color5
set -g fish_color_end            $color5
set -g fish_color_error          $color1
set -g fish_color_comment        $color8
set -g fish_color_operator       $color5
set -g fish_color_escape         $color3
set -g fish_color_autosuggestion $color8
set -g fish_color_selection      --background=$color0 $foreground
set -g fish_color_search_match   --background=$color10 $background
set -g fish_pager_color_prefix       $color4
set -g fish_pager_color_completion   $foreground
set -g fish_pager_color_description  $color8
set -g fish_pager_color_selected_background --background=$color0

# ====================== ALIAS ======================
alias bat="batcat"
alias shot="flameshot gui"
alias ll="ls -la"
alias ..="cd .."
alias e="exit"
alias brave="flatpak run com.brave.Browser &"
alias firecast='wine "/home/felipebc2/.wine/drive_c/users/felipebc2/AppData/Local/Firecast/Firecast.exe"'
alias rrpg='wine "/home/felipebc2/.wine/drive_c/users/felipebc2/AppData/Local/Firecast/Firecast.exe"'
alias rpg='wine "/home/felipebc2/.wine/drive_c/users/felipebc2/AppData/Local/Firecast/Firecast.exe"'

# ======================= PATH ======================
set -gx PATH $HOME/.venvs/tools/bin $PATH
set -gx PATH $HOME/.venvs/tools/bin $PATH

