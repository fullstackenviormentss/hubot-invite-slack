# Filter generators

module.exports =
  inviteByField: (field, needle) ->
	  (invite) ->
      if invite[field] is needle then true else false

  senderByField: (field, needle) ->
	  (invite) ->
      if invite.sender?[field] is needle then true else false

  userByField: (field, needle) ->
	  (user) ->
		  if user[field] is needle then true else false

  reduceInvite: (invite) ->
      invite.name or invite.email
