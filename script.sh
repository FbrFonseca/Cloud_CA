#!/bin/bash

PROJECT_ID="cloud-ca-456020"
ZONE="europe-west1-b"
REGION="europe-west1"
INSTANCE_NAME="cloud-ca"
MACHINE_TYPE="e2-standard-2"
DISK_SIZE="250gb"
IMAGE_FAMILY="ubuntu-2004-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
STATIC_IP_NAME="${INSTANCE_NAME}-ip"
FIREWALL_RULE_NAME="allow-http-ssh-$(date +%s)"

gcloud config set project $PROJECT_ID
gcloud config set compute/zone $ZONE

gcloud compute addresses create $STATIC_IP_NAME \
  --region=$REGION \
  --project=$PROJECT_ID

STATIC_IP=$(gcloud compute addresses describe $STATIC_IP_NAME \
  --region=$REGION \
  --format="get(address)")

gcloud compute instances create $INSTANCE_NAME \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --boot-disk-size=$DISK_SIZE \
  --address=$STATIC_IP \
  --tags=http-server,ssh \
  --project=$PROJECT_ID

gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
  --allow=tcp:22,tcp:80 \
  --target-tags=http-server \
  --description="Allow HTTP and SSH access" \
  --project=$PROJECT_ID

echo "VM created with ip: $STATIC_IP"