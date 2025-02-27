extends "res://singletons/utils.gd"	

func format_number(value: int) -> String:
	var suffixes := ["", "K", "M", "B", "T"]
	var num := float(value)
	var index := 0
	
	while num >= 1000.0 and index < suffixes.size() - 1:
		num /= 1000.0
		index += 1
	
	if index == 0:
		return str(value)
	
	return "%.2f%s" % [num, suffixes[index]]
