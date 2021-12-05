#!/bin/bash
set -e

if [ "${APPLY_CUSTOM_FILES}" = true ]; then
    echo "Moving in additional files"
    cp /tmp/Maps/*.unr /opt/ut-server/Maps/ 2>/dev/null || :
    cp /tmp/Textures/*.utx /opt/ut-server/Textures/ 2>/dev/null || :
    cp /tmp/Sounds/*.umx /opt/ut-server/Sounds/ 2>/dev/null || :
    cp /tmp/System/*.u /tmp/System/*.ini /tmp/System/*.int /opt/ut-server/System/ 2>/dev/null || :
fi

if [ -z "$SERVER_STRING" ]; then
    echo "Using default server string. To override, set SERVER_STRING environmental variable"
    SERVER_STRING="CTF-Coret?game=BotPack.CTFGame?mutator=BotPack.InstaGibDM"
fi

echo "Starting up server with '${SERVER_STRING}'"
/opt/ut-server/System/ucc-bin server "${SERVER_STRING}" userini=/opt/ut-server/System/User.ini ini=/opt/ut-server/System/UnrealTournament.ini -nohomedir -lanplay
