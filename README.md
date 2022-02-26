# arma_mods
<h1>ArmA 3 Linux Bash Script for Downloading and Updating ArmA 3 Dedicated Server and a corrosponding modslist.html file.<h1>

<h3>Usage<h3>
<pre>
./arma_mods.sh Arma_3_Preset_Modpack.html
</pre>
  <h3>What the fuck is it</h3>
 <p>
 I got annoyed and frustrated with the lack of information about running an ArmA 3 Dedicated Server on Linux with Mods.  Like, no one wants to talk about it for some reason.  Or no one's trying I guess.  So, I bumbled through it and wrote a horrible little script to do most of the mind-numbing work.  wherever you set the +armaModsDir+ to will need an almost unreasonable amount of space; I think mine is allocated something like 500GB, and it's currently using around 350GB.  It may need to be run more than once to download all the mods fully as Steam likes to timeout during mod downloads, and no log information explains if there's any auto-retry after failure.  Fucking thanks Gaben.
<p>
<pre>
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

cd $armaModsDir; find . -depth -exec rename --verbose 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \; ## Move to mods folder, minimize all names.  Try not to let it run away.

echo "making backup modslist.txt"
cd $modListDir; mv -fv modslist.txt modslist.txt.`date +%Y%m%d`.`date +%H%m%S`
for i in `cat $modListDir/$modList | grep \?id=.*\" | sed 's/^.*?id=\([[:alnum:]]*\)".*$/\1/g'`; do 
	echo -n "mods/$i;" >> modslist.txt; 
done
echo "modslist.txt done"
<pre>
