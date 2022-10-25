#!/bin/bash

### animate-wallpaper - display wallpaper for multiple screens based on xwinwrap
###
### Usage:
###   animate-wallpaper -b [mpv/sxiv/nsxiv/gifview] -s [F/f/d/w/h] -f [path/to/file]
###
### Options:
###   -b program   Select base program. mpv supports gifs and videos, others only support gifs.
###   -F           Whether only first display output, if option added, no matter value, only first display
###   -s STRETCH_MODE   mpv and gifview doesn't support STRETCH_MODE, sxiv doesn't support `F'
###                    [F]ill, [f]it, [d]own, [w]idth, [h]eight
###   -f filename  File absolute path
###   -m vistype   GLava visual type
###   -S source   Music visualization source "fifo"(default) or "pulseaudio"
###   -k           Terminate all animate wallpapers
###   -h           Show this message.

SOURCE="fifo"

while getopts "b:F:s:f:m:S:k:h" opt; do
    case $opt in
        b)
            case $OPTARG in 
                mpv)
                    base_command() {
                        xwinwrap -g $1 -d -ni -s -nf -b -un -ov -fdt -argb -debug -- mpv -wid WID --mute=yes --no-audio --no-osc --no-osd-bar --quiet --loop --hwdec=no --vo=xv --profile=sw-fast $2
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
        F)
            ONLY_FIRST="1"
        ;;        
        s)
            STRETCH_MODE=$OPTARG
        ;;
        f)
            FILE_NAME=$OPTARG
        ;;
        m)
            MUSIC_TYPES+=",${OPTARG}"
        ;;
        S)
            SOURCE=$OPTARG
        ;;
        k)
            killall -q xwinwrap && killall -q xwinwrap
            exit 0
        ;;
        h)
            sed -rn 's/^### ?//;T;p;' "$0"
            exit 0
        ;;
    esac
done

killall -q xwinwrap && killall -q xwinwrap

music() {
    xwinwrap -g $1 -ni -s -nf -a -un -ov -fdt -argb -o 0 -d -- glava -m $2 -a $3
}

SCREEN_LIST=$(xrandr --query | grep " connected" | sed -r 's/primary//' | awk '{print $3}')

MUSIC_TYPES="${MUSIC_TYPES//,/ }"

for var in $MUSIC_TYPES; do
    music $(echo $SCREEN_LIST | cut -d ' ' -f 1) $var $SOURCE;
done;

sleep 0.2

if [ -z $ONLY_FIRST ]; then
    for s in $SCREEN_LIST; do
        base_command $s $FILE_NAME $STRETCH_MODE;
    done;
else
    base_command $(echo $SCREEN_LIST | cut -d ' ' -f 1) $FILE_NAME $STRETCH_MODE
fi

exit 0
