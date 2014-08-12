#!/bin/bash
#
#
# Script for SMS-alerts from Atlassian Jira-issues to RadaR-employees and -directors. Tested on Debian Wheezy.
# by marc gilbert on 5. Aug 2014
# feedback to code@gilbert.me
#

## Variables, change this to your recipients phone-numbers

SMSContacts='0123456789;0123456789'

## Check if we can log into the database server and if not, exit this script.

if [ ! -f /root/.mysqlpw ]
  then echo "Can't connect to MySQL, please store MySQL passwd in /root/.mysqlpw" && exit 1;
fi

## Query the database for if there are any open (issuestatus=1) alarm (priority=1) tickets and extract only the subject. You have to change "CHANGEME" to your project id and JIRADBNAMEHERE to the name of your jira database.
## You can get this one by executing this query in your local MySQL shell (assuming you are already using the jira-db):
## SELECT * FROM project;

MySQLCMD=$(mysql -udebian-sys-maint -p`cat /root/.mysqlpw` -e "use JIRADBNAMEHERE; select * from jiraissue where priority='1' and issuestatus='1' and project=CHANGEME\G" | grep SUMMARY | cut -c 23-)

## Check if the output is zero, if yes don't send any sms.

if [ -z $MySQLCMD ]
 then exit 2;
fi


## If there are open alarms, parse them via curl to smskaufen.com API/gateway. Ensure that the account has enough credit.
## Sign up for an account at http://smskaufen.com/

curl --data "id=USERNAMEHERE&pw=PASSWORDHERE&type=4&text=[ALARM]%20`echo $MySQLCMD`&empfaenger=`echo $SMSContacts`&absender=SENDERNAME_HERE&massen=1&termin=01.01.2009-20:20" http://www.smskaufen.com/sms/gateway/sms.php?

exit
