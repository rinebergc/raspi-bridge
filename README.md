raspberry pi 4 wireless bridge setup script  
  
configure your pi's wireless connection  
curl -L https://raw.githubusercontent.com/rinebergc/raspi-bridge/main/router.sh -o router.sh  
chmod +x router.sh  
./router.sh  
chrontab -e  
\>> @reboot /home/pi/router.sh
    
connect your pi and the target device via ethernet  
your target device should now be able to access the internet
  
acknowldgements:  
raspi-bridge was forked from the following gist  
https://gist.github.com/Konamiman/110adcc485b372f1aff000b4180e2e10  
changes include: formatting fixes (removed bad line endings, removed incorrect file paths, etc.),  
auto config, logic to identify if the script has already been run and bypass first time setup.  
