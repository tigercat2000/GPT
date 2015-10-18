/proc/replacetext(text, find, replacement)
	return list2text(text2list(text, find), replacement)

/proc/replacetextEx(text, find, replacement)
	return list2text(text2listEx(text, find), replacement)