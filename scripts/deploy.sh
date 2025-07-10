
set -e

# for logging all output

exec > >(tee /var/log/deploy.log | logger -t deploy-script) 2>&1

#check for bucket name

if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh <bucket_name>"
  exit 1

fi

bucket_name=$1

#install java and git

sudo yum update -y
sudo yum install -y java-21-amazon-corretto git

#clone the repo

git clone --branch feature/devops-assignment-3 https://github.com/sohampatil44/techeazy-devops.git || true
 || true

cd techeazy-devops

# give ownership to ec2-user
sudo chown -R ec2-user:ec2-user .

# make maven wrapper executable
chmod +x mvnw

# build project
sudo -u ec2-user ./mvnw clean package

JAR_PATH="target/techeazy-devops-0.0.1-SNAPSHOT.jar"

if [ -f "$JAR_PATH" ]; then
  echo "Running app..."
  nohup java -jar "$JAR_PATH" --server.port=80 > /home/ec2-user/app.log 2>&1 &
else
  echo "Build failed."
  exit 1

fi

# Upload logs to S3 bucket

aws s3 cp /home/ec2-user/app.log s3://${bucket_name}/app/logs/
aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/system/ 

