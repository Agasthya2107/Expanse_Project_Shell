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
        echo "User should have $Y ROOT access $N to run the sofware"
        exit 1
    fi
}

echo -e "$Y Software execution proccess started at : $TIMESTAMP" &>>$LOG_FILE_NAME

USER_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "NODEJS Module Disabled"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "NODEJS Module Enabled"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "NODEJS Installed"

id expense &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then 
        echo "User allowed to add the new User"
        useradd expense &>>$LOG_FILE_NAME
        VALIDATE $? "New User EXPENSE Added"
    else
        echo -e "$R User already exists no need to create again $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating New APP Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Bacakup File Downloaded"

cd /app &>>$LOG_FILE_NAME
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Backed File Unzip is completed"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "NPM Installed"

cp /home/ec2-user/Expanse_Project_Shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "MYSQL Server Installed"

mysql -h  172.31.95.63 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon service reloaded"
 
systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Backend Enabled"

systemctl restart backend &>>$LOG_FILE_NAME
 VALIDATE $? "Backend Restarted"


