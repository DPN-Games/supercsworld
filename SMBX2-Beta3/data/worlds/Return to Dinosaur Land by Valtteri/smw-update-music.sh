grep -e "smw-bonus.mp3" *.lvl
sed -i -e "s/smw-bonus\.mp3/smw-bonus\.spc/g" *.lvl

grep -e "smw-bossdefeated.mp3" *.lvl
sed -i -e "s/smw-bossdefeated\.mp3/smw-bossdefeated\.spc/g" *.lvl

grep -e "smw-bowser.mp3" *.lvl
sed -i -e "s/smw-bowser\.mp3/smw-bowser\.spc/g" *.lvl

grep -e "smw-bowserfinal.mp3" *.lvl
sed -i -e "s/smw-bowserfinal\.mp3/smw-bowserfinal\.spc/g" *.lvl

grep -e "smw-eggrescued.mp3" *.lvl
sed -i -e "s/smw-eggrescued\.mp3/smw-eggrescued\.ogg/g" *.lvl

grep -e "smw-ending.mp3" *.lvl
sed -i -e "s/smw-ending\.mp3/smw-ending\.spc/g" *.lvl

grep -e "smw-princessrescued.mp3" *.lvl
sed -i -e "s/smw-princessrescued\.mp3/smw-princessrescued\.spc/g" *.lvl

grep -e "smw-starman.mp3" *.lvl
sed -i -e "s/smw-starman\.mp3/smw-starman\.spc/g" *.lvl

grep -e "smw-starroad.mp3" *.lvl
sed -i -e "s/smw-starroad\.mp3/smw-starroad\.spc/g" *.lvl

echo "Running UNIX2DOS..."
unix2dos *.lvl
echo "Finished!"
