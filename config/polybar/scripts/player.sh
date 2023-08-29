#!/bin/bash
#
#  _____ _______ _                         
# |_   _|__   __| |                        
#   | |    | |  | |__   ___ _ __ ___   ___ 
#   | |    | |  | '_ \ / _ \ '_ ` _ \ / _ \
#  _| |_   | |  | | | |  __/ | | | | |  __/
# |_____|  |_|  |_| |_|\___|_| |_| |_|\___|
#                                          
#ITheme Polybar Music Status                                         
#Based on https://github.com/Crash-Zeus
#Modified by Amelia Yukii (https://transfem.social/@Amelia)
#https://github.com/Insert5StarName
#
# Module for Music  Status
readonly command=$1
# Set Player
readonly PLAYER="firefox"
readonly ZSCROLL_DELAY="0.1"
readonly ZSCROLL_UPDATE_DELAY="2"
readonly ZSCROLL_LENGTH="35"
function get_status() {
    PLAYERCTL_STATUS=$(playerctl --player=$PLAYER status)
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        STATUS=$PLAYERCTL_STATUS
    else
        STATUS="No players found"
    fi
}

function get_metadata() {
    DATA=$(playerctl --player=$PLAYER metadata --format "$1")
    echo $DATA
}

function display_data() {
    if [ "$STATUS" = "Stopped" ]; then
        echo "No music is playing"
    elif [ "$STATUS" = "Paused"  ]; then
        get_metadata "Paused"
    elif [ "$STATUS" = "No player is running"  ]; then
        echo "$STATUS"
    else
        get_metadata "{{ title }} by {{ artist }}"
    fi
}

function display_status() {
    if [ "$STATUS" = "Stopped" ]; then
        echo ""
    elif [ "$STATUS" = "Paused"  ]; then
        echo ""
    elif [ "$STATUS" = "No player is running"  ]; then
        echo ""
    else
        echo ""
    fi
}

function exec_player_command() {
    readonly CMD=$1
    playerctl --player=$PLAYER $CMD
}

case $command in

    "--get-infos")
        get_status
        display_data
    ;;
 
    "--get-status")
        get_status
        display_status
    ;;
    
    "--scroll")
        $0 --get-infos | $HOME/.local/bin/zscroll -d $ZSCROLL_DELAY -U $ZSCROLL_UPDATE_DELAY -l $ZSCROLL_LENGTH -u true "`dirname $0`/player.sh --get-infos"
        # -d update scroll delay
        # -U launch update command delay
        # -l length of scrolling text
        # -u Update command
    ;;
    
    "--play-pause")
        get_status
        if [ "$STATUS" = "Playing" ] ; then
            exec_player_command pause
        elif [ "$STATUS" = "Paused" ] ; then
            exec_player_command play
        elif [ "$STATUS" = "Stopped" ] ; then
            exec_player_command play
        fi
    ;;

    "--next")
        exec_player_command next
    ;;

    "--previous")
        exec_player_command previous
    ;;

    *)
        echo "No command specified."
        echo ""
        echo "Available commands :"
        echo "--get-infos                   Get the song name if playing or return No playing song / Paused"
        echo "--get-status                  Get the current status of player like Playing | Stopped | Paused but return icon"
        echo "--scroll                      Display the song metadata with zscroll to scroll text"
        echo "--play-pause                  Execute play or pause command (depend on playerctl status)"
        echo "--next                        Execute next command"
        echo "--previous                    Execute previous command"
        exit 0
    ;;
esac

