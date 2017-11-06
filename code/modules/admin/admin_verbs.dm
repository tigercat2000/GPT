var/list/admin_verbs_admin = list(
	/client/proc/admin_ghost,
	/client/proc/admin_delete
)


/client/proc/give_admin_verbs()
	verbs += admin_verbs_admin
	verbs += /client/proc/debug_variables