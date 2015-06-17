# Hubot Invite to Slack

A simple script for Hubot to send invitations in Slack and track who is inviting whom.

This requires _hubot-auth_ to manage permissions.

## Installation

In hubot project repo, run:

`npm install hubot-invite-slack --save`

Then add **hubot-invite** and **hubot-auth** to your `external-scripts.json`:

```json
["hubot-auth", "hubot-invite-slack"]
```
