# n82wp
Effective Tool for Updating, Repairing and Scanning Wordpress CMS

n82wp is lightweight tool designed for anyone who wishes to update, repair or scan Wordpress CMS from any Linux distribution which have Bash installed.

It is based on : <BR>
1) WP-CLI (http://wp-cli.org/) <BR> 
2) Sucuri Scanner (https://sitecheck.sucuri.net/) <BR> 
3) Bash (https://en.wikipedia.org/wiki/Bash_(Unix_shell)) <BR> 

How to use n82wp tool? <BR>

First clone it on your server by executing: <BR> 
git clone https://github.com/nemke82/n82wp.git <BR>

or <BR>

wget -c https://raw.githubusercontent.com/nemke82/n82wp/master/n82wp.sh ; chmod a+rwx n82wp.sh <BR>

Next type: bash n82wp.sh <BR>

Help will be prompted, repeat with desired command. <BR>

Notes: <BR>
Type email address after scan command, if you wish to get alert on your email address. <BR>
ex. bash n82wp.sh scan ne@nemanja.io <BR>
