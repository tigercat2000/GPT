import sys
if len(sys.argv) < 2:
    print "Not enough argument supplied."
    quit()

import os
import re

weirdre = re.compile("^[0-9]")

def to_chat(string):
    tabs = string.count("\t")

    actuallytabs = ""

    while tabs > 0:
        actuallytabs += "\t"
        tabs -= 1

    ltpos = string.find("<<")
    if ltpos == -1:
        return string

    user = string[:ltpos]
    if user.find("diary") != -1 or user.find("world.log") != -1:
        return string

    if user.find("//") != -1:
        actuallytabs = "//" + actuallytabs
        user = user.replace("//", "")
    thingendpos = string[ltpos + 2:].find("//")
    if thingendpos == -1:
        thingendpos = len(string) - 1
    thing = string[ltpos + 2:][:thingendpos]
    thing = thing.strip()
    user = user.strip()
    if weirdre.search(thing) != None:
        return string

    comment = string[ltpos + 2:][thingendpos:]

    return actuallytabs + "to_chat(%s, %s)%s\r\n" % (user, thing, comment)

basicre  = re.compile("^[^<]*<<.*$")
outputre = re.compile("^[^<]*<<\s*(?:output|browse|browsersc).*$") 

print sys.argv[1]
for root, dirs, files in os.walk(sys.argv[1]):
    print root
    for filename in files:
        if filename[(len(filename) - 3):] != ".dm":
            continue

        absolute = os.path.join(root, filename)

        print absolute

        f = open(absolute, "r")
        lines = f.readlines()
        f.close()

        f = open(absolute, "w")

        for line in lines:
            if basicre.search(line) != None:
                #uh
                if outputre.search(line) == None:
                    line = to_chat(line)
            f.write(line)

        f.close()