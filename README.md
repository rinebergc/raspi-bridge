raspberry pi 4 wireless bridge setup script  
  
curl -L https://github.com/rinebergc/raspi-bridge/archive/refs/heads/main.zip -o raspi-bridge.zip  
unzip raspi-bridge.zip  
chmod +x raspi-bridge-main/router.sh  
raspi-bridge-main/router.sh  
chrontab -e >> @reboot /home/pi/router.sh
  
configure your pi's wireless connection  
connect your pi and the target device via ethernet  
your target device should now be able to access the internet
  
acknowldgements:  
raspi-bridge was forked from the following gist  
https://gist.github.com/Konamiman/110adcc485b372f1aff000b4180e2e10  
changes include: formatting fixes (no more bad line endings, no more incorrect file paths, etc.),  
auto config, logic to identify if the script has already been run and bypass first time setup.  
