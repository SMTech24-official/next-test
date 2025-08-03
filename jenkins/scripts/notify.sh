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

if [[ -z "$contributors" ]]; then
    echo "❌ No contributors found in git log."
    exit 1
fi

echo "📨 Sending '$DEPLOYMENT_STATUS' deployment notifications for $REPO_NAME..."

echo "$contributors" | while read -r line; do
    name=$(echo "$line" | sed -E 's/(.*)<.*/\1/' | xargs)
    email=$(echo "$line" | sed -E 's/.*<([^>]+)>.*/\1/')

    # Skip noreply emails
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

    # Send email using Postfix's `mail` command
    echo "$BODY" | mail -s "$SUBJECT" "$email"

    if [[ $? -eq 0 ]]; then
        echo "✅ Email sent to $name <$email>"
    else
        echo "❌ Failed to send email to $name <$email>"
    fi
done
