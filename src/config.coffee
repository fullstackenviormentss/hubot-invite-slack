# From the basic messages interface, execute $("ul#channel-list li.channel").each(function (index, el) {console.log("Channel " + $("span.overflow-ellipsis", $(el)).text().replace(/\s/g,'') + " is identifed as " + $("a.channel_name", $(el)).data("channel-id"));});

module.exports =
  channels: process.env.HUBOT_SLACK_INVITE_CHANNELS or ""
  team: process.env.HUBOT_SLACK_TEAM or "my-team"
  token: process.env.HUBOT_SLACK_TOKEN or "token"
  brainKey: "slack.invites"
