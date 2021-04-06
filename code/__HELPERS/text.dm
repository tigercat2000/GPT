//Returns a string with the first element of the string capitalized.
/proc/capitalize(t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Replaces \red \blue \green \b etc with span classes for to_chat
/proc/replace_text_macro(match, code, rest)
	var/regex/text_macro = new("(\\xFF.)(.*)$")
	switch(code)
		if("\red")
			return "<span class='warning'>[text_macro.Replace(rest, /proc/replace_text_macro)]</span>"
		if("\blue", "\green")
			return "<span class='notice'>[text_macro.Replace(rest, /proc/replace_text_macro)]</span>"
		if("\b")
			return "<b>[text_macro.Replace(rest, /proc/replace_text_macro)]</b>"
		else
			return text_macro.Replace(rest, /proc/replace_text_macro)

/proc/macro2html(text)
	var/static/regex/text_macro = new("(\\xFF.)(.*)$")
	return text_macro.Replace(text, /proc/replace_text_macro)

//Removes a few problematic characters
/proc/sanitize_simple(t,list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index + length(char))
			index = findtext(t, char, index + length(char))
	return t

/proc/sanitize_filename(t)
	return sanitize_simple(t, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))
