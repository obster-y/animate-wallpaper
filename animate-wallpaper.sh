#!/bin/bash

### animate-wallpaper - display wallpaper for multiple screens based on xwinwrap
###
### Usage:
###   animate-wallpaper -b [mpv/sxiv/nsxiv/gifview] -s [F/f/d/w/h] -f [path/to/file]
###
### Options:
###   -b program   Select base program. mpv supports gifs and videos, others only support gifs.
###   -s stretch   mpv and gifview doesn't support stretch, sxiv doesn't support `F'
###                    [F]ill, [f]it, [d]own, [w]idth, [h]eight
###   -f filename  File absolute path
###   -h           Show this message.

help() {
    sed -rn 's/^### ?//;T;p;' "$0"
}

while getopts "b:s:f:h" opt; do
    case $opt in
        b)
            case $OPTARG in 
                mpv)
                    base_command() {
                        xwinwrap -g $1 -d -ni -s -nf -b -un -ov -fdt -argb -o 1.0 -debug -- mpv -wid WID --mute=yes --no-audio --no-osc --no-osd-bar --quiet --loop --hwdec=no --vo=xv --profile=sw-fast $2
                    }

                ;;
                sxiv)
                    base_command() {
                        xwinwrap -g $1 -d -ni -s -nf -b -un -ov -fdt -debug -- sxiv -e WID -abpq -g ${1/%\+[0-9]*\+[0-9]*/} -s $3 $2
                    }

                ;;
                nsxiv)
                    base_command() {
                        xwinwrap -g $1 -d -ni -s -nf -b -un -ov -fdt -debug -- nsxiv -e WID -abpq -g ${1/%\+[0-9]*\+[0-9]*/} -s $3 $2
                    }
                ;;
                gifview)
                    base_command() {
                        xwinwrap -g $1 -d -ni -s -nf -b -un -ov -fdt -argb -o 1.0 -debug -- gifview -w WID -a +e --memory-limit 1024 --geometry ${1/%\+[0-9]*\+[0-9]*/} $2
                    }
                ;;
            esac
        ;;
        s)
            stretch=$OPTARG
        ;;
        f)
            fname=$OPTARG
        ;;
        h)
            help
            exit 0
        ;;
    esac
done

killall -q xwinwrap
screens=$(xrandr --query | grep " connected" | sed -r 's/primary//' | awk '{print $3}')

for s in $screens; do
    base_command $s $fname $stretch;
done;
exit 0
