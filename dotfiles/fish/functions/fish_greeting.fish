function fish_greeting
    set -l LEFT_COL 52
    set -l cyan   (set_color cyan)
    set -l normal (set_color normal)

    # ====== ARTE ======
    set -l art \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣤⡀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⣿⣿⣆⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣶⠆⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⡇⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣁⣤⣤⣴⣶⣶⣤⣤⣄⣀⠀⠀⠀⣸⣿⣿⣿⡇⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣴⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⡿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠟⠁⠀⠹⣿⣿⡟⣰⠋⠀⠀⠈⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢼⣿⠀⠀⠀⢀⣿⣿⣇⣇⠀⠀⠀⠀⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣦⣀⣠⣾⣿⣿⣿⣿⣤⣀⣠⣾⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⡿⣧⣀⣤⣴⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀" \
"⠀⢠⣾⣿⠟⠉⣸⣿⣿⣿⠟⠉⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣄⡀⠀⠀⠀" \
"⢰⣿⡿⠁⠀⠀⣿⣿⡿⠁⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀" \
"⣾⣿⠁⠀⠀⠀⣿⣿⣷⣿⣿⠿⠛⠉⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⠛⠛⠻⠈⠙⠀" \
"⢻⣿⡀⠀⢠⣾⣿⣿⡟⠉⠀⠀⠀⠀⠹⣿⣿⣇⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣤⣤⡾" \
"⠘⢿⡇⢠⡿⠋⢹⣿⡇⠀⠀⠀⠀⠀⠀⠹⣿⣿⡆⠀⠀⠉⠻⣿⣿⡿⠿⠿⣿⣿⣷⡉⠙⢿⣿⣟⠛⠉⠁" \
"⠀⢘⡿⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⡄⠀⠀⠀⢹⣿⠀⠀⠀⠀⠈⠹⣷⠀⠀⠙⢿⣆⣀⣀" \
"⠀⠈⠁⠀⠀⠀⠀⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡇⠀⠀⠀⠘⠿⣦⠀⠀⠀⠀⠀⠛⠀⠀⠀⠀⠉⠉⠁" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠁⠀⠀                 "

    # ====== INFOS ======
    set -l user     $USER
    set -l host     (hostname)
    set -l distro   (grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    if test -z "$distro"
        set distro (uname -s)
    end
    set -l kernel   (uname -sr)
    set -l uptime_v (uptime -p 2>/dev/null | string replace 'up ' '')
    if test -z "$uptime_v"
        set uptime_v (uptime | awk -F'up ' '{print $2}' | cut -d, -f1)
    end
    set -l shellp   $SHELL
    set -l termn    $TERM
    set -l tcols    (tput cols 2>/dev/null); set -l tlines (tput lines 2>/dev/null)
    set -l termsz   "$tcols x $tlines"
    set -l cpu (awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null)
    set -l mem_used (free -h | awk '/Mem:/ {print $3}')
    set -l mem_tot  (free -h | awk '/Mem:/ {print $2}')
    set -l mem      "$mem_used / $mem_tot"
    set -l disk (df -h / | awk 'NR==2{print $5" ("$3"/"$2")"}')
    set -l bat "-"
    if type -q acpi
        set bat (acpi -b | awk -F', ' 'NR==1{print $2}')
    else if type -q upower
        set bat (upower -e | grep BAT -m1 | xargs -I{} upower -i {} | awk -F': *' '/percentage/ {print $2; exit}')
    end
    set -l datev (date "+%a %d %b %Y %H:%M")

    set -l info \
"$cyan User:$normal $user" \
"$cyan Hostname:$normal $host" \
"$cyan Distro:$normal $distro" \
"$cyan Kernel:$normal $kernel" \
"$cyan Uptime:$normal $uptime_v" \
"$cyan Shell:$normal $shellp" \
"$cyan Terminal:$normal $termn" \
"$cyan Terminal Size:$normal $termsz" \
"$cyan CPU:$normal $cpu" \
"$cyan Memory:$normal $mem" \
"$cyan Disk:$normal $disk" \
"$cyan Battery:$normal $bat" \
"$cyan Date:$normal $datev"

    # ====== ALINHAMENTO ======
    set -l len_art  (count $art)
    set -l len_info (count $info)
    set -l maxlen $len_art
    if test $len_info -gt $len_art
        set maxlen $len_info
    end

    for i in (seq $maxlen)
        set -l left  ""
        set -l right ""
        if test $i -le $len_art;  set left  $art[$i];  end
        if test $i -le $len_info; set right $info[$i]; end
        if test -n "$right"
            printf "%-*s  %s\n" $LEFT_COL "$left" "$right"
        else
            printf "%s\n" "$left"
        end
    end
    echo
end

