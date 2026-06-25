#!/bin/bash

set -e

APP_NAME="roho_backend_core"
REPO_URL="https://solbaacken.git.beanstalkapp.com/roho_backend_core.git"
BRANCH="preprod"

BASE_DIR="/home/ubuntu/deploy1"
REPO_DIR="$BASE_DIR/roho_backend_repo"

ENV_FILE="/home/ubuntu/env-files/roho_backend.env"
LOCAL_DOCKERFILE="/home/ubuntu/deploy1/Dockerfile"

IMAGE_NAME="$APP_NAME:latest"
CONTAINER_NAME="$APP_NAME-container"

echo "=============================="
echo "🚀 Backend Deployment Started"
echo "=============================="

# 1. Clone or update repo
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "🔹 Cloning repository..."
    git clone -b $BRANCH $REPO_URL $REPO_DIR
fi

cd $REPO_DIR

echo "🔹 Fetching latest code..."
git fetch origin $BRANCH
git reset --hard origin/$BRANCH

# 2. Copy .env from server
echo "🔹 Copying .env file..."
cp $ENV_FILE .env

# 3. Copy Dockerfile from local server
echo "🔹 Copying Dockerfile..."
cp $LOCAL_DOCKERFILE ./Dockerfile

# 4. Build Docker image
echo "🔹 Building Docker image..."
docker build -t $IMAGE_NAME .

# 5. Stop old container
echo "🔹 Stopping old container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# 6. Run new container
echo "🔹 Running container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 8081:8081 \
  --restart always \
  $IMAGE_NAME

echo "=============================="
echo "✅ Backend Deployment Successful"
echo "=============================="
