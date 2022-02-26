#!/bin/bash
##
## Usage: ./arma_mods.sh Arma_3_Modslist.html
##
userLogin=example@login.com  ## I typically hardcode this in.  No idea if it'll work as a variable.
armaModsDir=/home/ec2-user/ArmA/mods
modListDir=/home/ec2-user
modList=$1
getMods=$(for i in `cat $modListDir/$modList | grep \?id=.*\" | sed 's/^.*?id=\([[:alnum:]]*\)".*$/\1/g'`; do printf "%s;" "mods/$i"; done)

cat <<EOF > modslist
// ArmA Mod Downloader `date +%Y%m%d`
@ShutdownOnFailedCommand 0
login $userLogin
app_update 233780 validate
@sSteamCmdForcePlatformType "windows"
EOF

for i in `cat $modListDir/$modList | grep \?id=.*\" | sed 's/^.*?id=\([[:alnum:]]*\)".*$/\1/g'`; 
	do printf "%s\n" "workshop_download_item 107410 $i validate" >> modslist; 
done

echo "quit" >> modslist
steamcmd +runscript $modListDir/modslist
echo ""
echo "minimizing file names"
echo ""

## Move to mods folder, minimize all names.  Try not to let it run away.
cd $armaModsDir; find . -depth -exec rename --verbose 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;

echo "making backup modslist.txt"
cd $modListDir; mv -fv modslist.txt modslist.txt.`date +%Y%m%d`.`date +%H%m%S`
for i in `cat $modListDir/$modList | grep \?id=.*\" | sed 's/^.*?id=\([[:alnum:]]*\)".*$/\1/g'`; do 
	echo -n "mods/$i;" >> modslist.txt; 
done
echo "modslist.txt done"
