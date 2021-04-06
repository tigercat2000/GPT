/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa,2,4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa,4,6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa,6,8))

/proc/GetHexColors(const/hexa)
	return list(
			GetRedPart(hexa),
			GetGreenPart(hexa),
			GetBluePart(hexa)
		)
		
/// Generate a filename for this asset
/// The same asset will always lead to the same asset name
/// (Generated names do not include file extention.)
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"
