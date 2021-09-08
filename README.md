raspberry pi 4 wireless bridge setup script  
  
1. execute "sudo raspi-config" and configure your pi's wireless settings and localization options  
2. curl -L https://raw.githubusercontent.com/rinebergc/raspi-bridge/main/raspi-bridge.sh -o ~/raspi-bridge.sh  
3. chmod +x ~/raspi-bridge.sh && ~/raspi-bridge.sh  
4. execute "chrontab -e" and append "@reboot /home/pi/rasapi-bridge.sh" to the file
5. connect your pi and the target device via ethernet, your target device should now be able to access the internet  
  
acknowldgements:  
raspi-bridge was forked from the following gist  
https://gist.github.com/Konamiman/110adcc485b372f1aff000b4180e2e10  
changes include: formatting fixes (removed bad line endings, removed incorrect file paths, etc.),  
auto config, env performance optimization, and logic to identify if the script has already been run and bypass first time setup.  
