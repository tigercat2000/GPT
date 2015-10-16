/proc/get_turf(atom/A)
	if (!istype(A))
		return
	for(A, A && !isturf(A), A=A.loc); //semicolon is for the empty statement
	return A

/proc/subtypesof(var/path) //Returns a list containing all subtypes of the given path, but not the given path itself.
	if(!path || !ispath(path))
		CRASH("Invalid path, failed to fetch subtypes of \"[path]\".")
	return (typesof(path) - path)