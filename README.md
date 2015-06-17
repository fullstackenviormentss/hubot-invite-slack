# Hubot Invite to Slack

[![Build Status](https://travis-ci.org/impleri/hubot-invite-slack.svg?branch=master)](https://travis-ci.org/impleri/hubot-invite-slack)

A simple script for Hubot to send invitations in Slack and track who is inviting whom.

This requires _hubot-auth_ to manage permissions.

## Installation

In hubot project repo, run:

`npm install hubot-invite-slack --save`

Then add **hubot-invite-slack** and **hubot-auth** to your `external-scripts.json`:

```json
["hubot-auth", "hubot-invite-slack"]
```
