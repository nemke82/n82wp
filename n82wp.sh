#!/bin/bash
# Program:
# Wordpress Malware Scanner / Updater
# History:
# 2016-10-29 Nemke82 First release.
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH

params=$#
param1=$1
param2=$2

function show_help(){
cat <<EOF
    Usage: 
    bash n82wp.sh update           Update Wordpress theme and plugins.
    bash n82wp.sh repair           This will repair current Wordpress installation with backup in case of disaster.
    bash n82wp.sh scan             Scan site with Sucuri, Install Wordfence scanner, Create temp. username and email results. 
    bash n82wp.sh -h               show this help.
EOF
}

function update(){
    if [[ "$param1" == "update" ]];then
    echo "Checking if wp-cli tool is installed".
    elif [ ! -f /usr/local/bin/wp ];then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar &&
    sudo mv wp-cli.phar /usr/local/bin/wp
    fi
    echo "NOTE: Checking Wordpress installation"
    VERSION=$(wp core version)
    THEME=$(wp theme status)
    PLUGINS=$(wp plugin status)
    SITE=$(wp option get siteurl | cut -c 8-)
    printf "$VERSION\n"
    printf "$PLUGINS\n"
    printf "$THEME\n";
    printf "Please make backup before moving forward. In case you wish to update Themes or Plugins selectively,\n"
    printf "press N key and then use wp tool from your terminal\n"
    read -p "Do you want to update Core, Themes and Plugins for this $SITE website? <y/N>" prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
wp core update &&
wp theme update --all &&
wp plugin update --all &&

    echo "done."
fi
}

function repair(){
    if [[ "$param1" == "repair" ]];then
    echo "Checking if wp-cli tool is installed".
    elif [ ! -f /usr/local/bin/wp ];then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar &&
    sudo mv wp-cli.phar /usr/local/bin/wp
fi
SITE=$(wp option get siteurl | cut -c 8-)
printf "Repair tool will create core-(today-date).tar.gz archive at folder where your Wordpress installation is located,\n"
read -p "Do you want to proceed and repair $SITE website? <y/N>" prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
echo "Trying to repair your $SITE wordpress installation... please hold on..." ;

if [[ -e wp-includes/version.php ]] && [[ ! -d wordpress ]];then 
numba=$(grep "wp_version =" wp-includes/version.php|grep -Po "\d+.*"|cut -f1 -d\');
echo "Getting Wordpress version which is currently installed..."
wget --no-check-certificate wordpress.org/wordpress-$numba.zip > /dev/null 2>&1;
echo "Extracting data..."
unzip wordpress-$numba.zip > /dev/null 2>&1; 
echo "Correcting permissions and ownerships..."
chown -R $(pwd -P|cut -f3 -d/):$(pwd -P|cut -f3 -d/) wordpress;stamp=$(date +"%Y-%m-%d_%H-%M");
echo "Creating backup"
tar czf core_old-$stamp.tar.gz $(find wordpress/ -type f |sed 's/wordpress\///g') > /dev/null 2>&1;
chown $(pwd -P|cut -f3 -d/):$(pwd -P|cut -f3 -d/) core_old-$stamp.tar.gz;yes|cp -arf wordpress/* . > /dev/null 2>&1;
echo "Removing temp. folder"
rm -rf wordpress wordpress-$numba.zip;else echo "wp-includes not found or wordpress folder exists";fi

fi
}

function scan(){
    if [[ "$param1" == "scan" ]];then
    echo "Checking if wp-cli tool is installed".
    elif [ ! -f /usr/local/bin/wp ];then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar &&
    sudo mv wp-cli.phar /usr/local/bin/wp
fi
echo "Clearing tmp..."
rm -f /tmp/malwarecheck.txt &&
rm -f /tmp/malwarecheckemail.txt
SITE=$(wp option get siteurl | cut -c 8-)
EMAIL="$param2"
HOSTNAME=$(hostname)
PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
SENDEMAIL=0

if [[ "$EMAIL" == "" ]] 
then
EMAIL="root@$HOSTNAME"
fi

for s in $SITE
do
	WARNING=0
	> /tmp/malwarecheck.txt
	links -dump https://sitecheck.sucuri.net/results/$s | sed -n "/Infected/p" >> /tmp/malwarecheck.txt
	while read line; do
		if [[ "$line" == "[15]Infected with Malware" ]]
		then
			WARNING=1
		fi
	done < /tmp/malwarecheck.txt
	if [ $WARNING -eq 1 ]
	then
        	SENDEMAIL=1
		echo "https://sitecheck.sucuri.net/results/$s" >> /tmp/malwarecheckemail.txt
		cat /tmp/malwarecheck.txt >> /tmp/malwarecheckemail.txt
		echo "" >> /tmp/malwarecheckemail.txt
		echo "" >> /tmp/malwarecheckemail.txt
echo "MALWARE DETECTED!!! https://sitecheck.sucuri.net/results/$s"
	fi
done
if [ $SENDEMAIL -eq 1 ]
then
echo "Sending email if specified..."

wordfence=$(pwd -P)"/wp-content/plugins/wordfence"
echo "Checking if Wordfence plugin is installed"
    elif [ ! -d $wordfence ];then
echo "Installing Wordfence plugin."
wp plugin install wordfence &&
echo "Activating plugin."
wp plugin activate wordfence
fi
wp user create temp$PASSWORD $EMAIL --role=administrator --user_pass=$PASSWORD &&
echo -e "Please login to the Dashobard using following details: \n" >> /tmp/malwarecheckemail.txt
echo -e "username: temp$PASSWORD \n" >> /tmp/malwarecheckemail.txt
echo -e "password: $PASSWORD \n" >> /tmp/malwarecheckemail.txt >> /tmp/malwarecheckemail.txt

cat /tmp/malwarecheckemail.txt &&

mail -s "URGENT: Malware detected! Wordfence installed,review site!" $EMAIL < /tmp/malwarecheckemail.txt
echo "This is completed, good luck."
}

function main(){
    case "$params" in
        "0")
            show_help;
            exit 0;
            ;;
        "1" | "2")
            if [[ "$param1" == "-h" ]];then
                show_help;
            elif [[ "$param1" == "update" ]];then
                update;
            elif [[ "$param1" == "repair" ]];then
                repair;
            elif [[ "$param1" == "scan" ]];then
                scan;
            else

                show_help;
            fi
            exit 0;
            ;;
        *)
            show_help;
            exit 0;
            ;;
    esac
}

main;
