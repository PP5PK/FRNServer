#!/bin/bash
# ==============================================================================
# message_hook.sh - FRN Server Message Hook
# Brazil-FRN | dvbr.net | PP5PK
# ==============================================================================
# Parameters received from FRNServer:
#   $1  - Message text
#   $2  - Type: P (private) or A (public)
#   $3  - Callsign and name of sender
#   $4  - Location
#   $5  - Band/channel
#   $6  - Description
#   $7  - Country
#   $8  - Client session ID
#   $9  - Full path to server config file
#   $10 - Server PID
# ==============================================================================

MSG="$1"
TYPE="$2"
CALL="$3"
SID="$8"
CONFIG="$9"

FRNS="/usr/src/FRNServer/FRNServer"

# Helper: send private message to the caller
reply() {
    "$FRNS" private "$SID" "$1" "$CONFIG"
}

# Helper: send public message to the room
broadcast() {
    "$FRNS" public "$1" "$CONFIG"
}

# Normalize: lowercase, trim leading/trailing spaces
CMD=$(echo "$MSG" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Only process messages starting with #
[[ "$CMD" != \#* ]] && exit 0

# Extract command and optional argument
COMMAND=$(echo "$CMD" | awk '{print $1}')
ARG=$(echo "$CMD" | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//' | tr '[:lower:]' '[:upper:]')

case "$COMMAND" in

    "#help")
        reply "--- Available commands ---"
        reply "#help       - Show this help"
        reply "#info       - Server information"
        reply "#who        - List users in current room"
        reply "#who_all    - List users in all rooms"
        reply "#qrz <call> - QRZ.com lookup for a callsign"
        reply "#ping       - Check if server is responding"
        ;;

    "#info")
        reply "--- Brazil-FRN Server ---"
        reply "Address : Brazil-FRN.dvbr.net | pp5pk.net"
        reply "Port    : 10024"
        reply "Owner   : PP5PK - Daniel K | Mafra, SC, Brazil"
        reply "Website : https://dvbr.net"
        ;;

    "#ping")
        reply "Pong! Server is up and running. 73 de PP5PK"
        ;;

    "#who")
        reply "--- Users in current room ---"
        NETWORK=$("$FRNS" network "$CONFIG" 2>/dev/null)
        if [ -n "$NETWORK" ]; then
            USERLIST=$("$FRNS" listnet "$NETWORK" "$CONFIG" 2>/dev/null)
            if [ -n "$USERLIST" ]; then
                while IFS= read -r line; do
                    [ -n "$line" ] && reply "$line"
                done <<< "$USERLIST"
            else
                reply "(no users found)"
            fi
        else
            reply "(could not determine current room)"
        fi
        ;;

    "#who_all")
        reply "--- Users in all rooms ---"
        USERLIST=$("$FRNS" list "$CONFIG" 2>/dev/null)
        if [ -n "$USERLIST" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && reply "$line"
            done <<< "$USERLIST"
        else
            reply "(no users connected)"
        fi
        ;;

    "#qrz")
        if [ -z "$ARG" ]; then
            reply "Usage: #qrz <callsign>  (e.g. #qrz PP5PK)"
        else
            reply "QRZ lookup for $ARG: https://www.qrz.com/db/$ARG"
        fi
        ;;

    "#"*)
        reply "Unknown command: $COMMAND  |  Type #help for available commands."
        ;;

esac

exit 0
