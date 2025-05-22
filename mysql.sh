#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FILE_FOLDER="/var/log/expanse_project_sheell-log"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%s-%H-%M-%S)
LOG_FILE_NAME="$LOG_FILE_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE()
{
    if [ $1 -ne 0 ]
    then 
        echo -e "installation failed $R $2 $N"
        exit 1
    else
        echo -e "installed successfully $G $2 $N"
    fi    
}
USER_ROOT()
{
    if [ $USERID -ne 0 ]
    then 
        echo -e "User should have $Y ROOT access $N to run the sofware"
        exit 1
    fi
}

echo -e "$Y Software execution proccess started at : $TIMESTAMP" &>>$LOG_FILE_NAME

USER_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling MYSQL Server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting MYSQL Server"

mysql -h 44.211.252.216 -u root -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo -e "$Y User allowed to setup the Password"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE_NAME
    VALIDATE $? "Secure Password Setup to the server"
else
    echo -e "$R User password already avaliable"
fi



