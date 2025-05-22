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
        echo -e "installation failed $R  $2"
        exit 1
    else
        echo -e "installed successfully $G $2"
    fi
}

USER_ROOT()
{
    if [ $USERID -ne 0 ]
    then 
        echo "User should have $Y ROOT access $N to run the sofware"
        exit 1
    fi
}

echo -e "$Y Software execution proccess started at : $TIMESTAMP" &>>$LOG_FILE_NAME

USER_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Nginx Installed"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabled NGINX"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "NGINX Started"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading Latest code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping the frontend code"

cp /home/ec2-user/Expanse_Project_Shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "Copied expense config"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting nginx"