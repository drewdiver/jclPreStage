#!/bin/sh

JAMF="/usr/local/bin/jamf"
DEPLOG="/var/tmp/depnotify.log"

################################### INITIAL SETUP ########################################

echo "STARTING DEPNOTIFY RUN" >> "$DEPLOG"

# set a main image
echo "Command: Image: /usr/local/management/logos/company_logo.png" >> "$DEPLOG"

# set the main title
echo "Command: MainTitle: Welcome!" >> "$DEPLOG"

# set body text
echo "Command: MainText: We want you to have a few applications and settings configured before you get started with your new Mac. This process should take ~20 minutes to complete. \n \n If you need additional software or help, please visit the Self Service Portal app in your Applications folder or in your Dock." >> "$DEPLOG"

echo "Status: Preparing new machine" >> "$DEPLOG"

# we are running 5 policy events
echo "Command: Determinate: 5" >> "$DEPLOG"

echo "Status: Preparing..." >> "$DEPLOG"

##################################### ASSET CHECK ########################################

# ensure the boot drive is properly labeled "Macintosh HD"
if ! diskutil list | grep -q "Macintosh HD"
then
	echo "Command: MainTitle: Error Code: E0004" >> "$DEPLOG"
	echo "Command: MainText: The boot drive is not named Macintosh HD, please contact Help Desk for support at 555-555-5555" >> "$DEPLOG"
	echo "Status: Setup Failed" >> "$DEPLOG"
	# halt by entering a nearly infinite sleep
    while true; do sleep 86400; done;
fi

# wait to ensure the jamf binary is present
until [ -f /usr/local/bin/jamf ]
do
    sleep 2
done

# running caffeinate can be handy if you have a few policies that take time
echo "Command: Status: Caffeinating..." >> "$DEPLOG"

/usr/bin/caffeinate -disu&

# get the caffeinate PID so we can kill at the end
CPID="$!"

#################################### JAMF TRIGGERS #######################################

sleep 2
echo "Status: Installing Jamf Connect Sync..." >> "$DEPLOG"
"$JAMF" policy -event install_jamf_connect_sync

sleep 2
echo "Status: Configuring Jamf Connect Sync..." >> "$DEPLOG"
"$JAMF" policy -event install_jamf_connect_sync_la

sleep 2
echo "Status: Setting Computer Name..." >> "$DEPLOG"
"$JAMF" policy -event set_hostname

sleep 2
echo "Status: Enabling Apple Automatic Updates..." >> "$DEPLOG"
"$JAMF" policy -event enable_apple_automatic_updates

sleep 2
echo "Status: Finalizing..." >> "$DEPLOG"
"$JAMF" policy -event touch_deployment_complete

###################################### CLEAN UP ##########################################
sleep 2

echo "Command: Quit: Setup Complete!" >> "$DEPLOG"

rm /var/tmp/depnotify*
rm /var/tmp/com.depnotify.*

# change back to non-Notify mode or you will go through DEPNotify every reboot
# if you want to provision the user with Okta and switch back to the macOS login you can 
#     also just /usr/local/bin/authchanger -reset
/usr/local/bin/authchanger -reset -Okta

# stop the caffeinate process
kill $CPID

# self-destruct!
rm "$0"
