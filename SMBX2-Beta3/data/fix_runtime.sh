#!/bin/bash

# Adding system attribute for folders to allow them has icons
attrib +s graphics
attrib +s graphics/block
attrib +s graphics/effect
attrib +s graphics/player
attrib +s graphics/constumes
attrib +s graphics/bowser
attrib +s graphics/juni
attrib +s graphics/klonoa
attrib +s graphics/level
attrib +s graphics/link
attrib +s graphics/luaResources
attrib +s graphics/luigi
attrib +s graphics/mario
attrib +s graphics/megaman
attrib +s graphics/ninjabomberman
attrib +s graphics/npc
attrib +s graphics/particles
attrib +s graphics/path
attrib +s graphics/peach
attrib +s graphics/princessrinka
attrib +s graphics/rozalina
attrib +s graphics/samus
attrib +s graphics/scene
attrib +s graphics/snake
attrib +s graphics/tile
attrib +s graphics/toad
attrib +s graphics/ultimaterinka
attrib +s graphics/unclebroadword
attrib +s graphics/wario
attrib +s graphics/yoshi
attrib +s graphics/zelda
attrib +s LuaScriptsLib
attrib +s worlds

# Convert LF's into CRLF's
find . -type d -exec unix2dos {}/*.txt \;
find . -type d -exec unix2dos {}/*.lua \;
find . -type d -exec unix2dos {}/*.lvl \;
find . -type d -exec unix2dos {}/*.wld \;
git config core.autocrlf true

echo
echo "Everything has been done!"
