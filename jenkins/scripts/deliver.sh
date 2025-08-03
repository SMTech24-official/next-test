#!/usr/bin/env sh
set -e

echo '📦 Building the NextJS application...'
set -x
npm run build
set +x

echo '🚀 Starting the production server with PM2...'
set -x
if pm2 restart ecosystem.config.js; then
    STATUS="successful"
else
    STATUS="unsuccessful"
fi
sleep 2
pm2 save
set +x

DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$DIR/notify.sh"

# Pass the STATUS to notify.sh
"$DIR/notify.sh" "$STATUS"

echo ''
echo '✅ The app is running at: http://localhost:4000'
