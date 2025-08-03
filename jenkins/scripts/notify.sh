#!/bin/bash

DEPLOYMENT_STATUS="$1"
if [[ -z "$DEPLOYMENT_STATUS" ]]; then
    echo "❌ Usage: $0 <deployment_status>"
    exit 1
fi

REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
if [[ -z "$REPO_NAME" ]]; then
    echo "❌ Unable to detect repo name from Git."
    exit 1
fi

contributors=$(git log --pretty=format:"%an <%ae>" | sort -u)

echo "📨 Sending '$DEPLOYMENT_STATUS' deployment notifications for $REPO_NAME..."
echo "$contributors" | while read -r line; do
    name=$(echo "$line" | sed -E 's/(.*)<.*/\1/' | xargs)
    email=$(echo "$line" | sed -E 's/.*<([^>]+)>.*/\1/')

    if [[ "$email" == *noreply* || -z "$email" ]]; then
        continue
    fi

    SUBJECT="[$REPO_NAME] 🚀 Deployment $DEPLOYMENT_STATUS"
    BODY=$(cat <<EOF
Dear $name,

The deployment for repository "$REPO_NAME" was **$DEPLOYMENT_STATUS**.
Timestamp: $(date)

Best regards,
Deployment Bot
EOF
)

    echo "$BODY" | mail -s "$SUBJECT" "$email"
    echo "✅ Email sent to $name <$email>"
done
