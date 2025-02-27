extends "res://singletons/utils.gd"	

func format_number(n: float) -> String:
	if n >= 1_000_000_000:
		return str(round(n / 1_000_000_000.0 * 100) / 100) + "B"
	elif n >= 1_000_000:
		return str(round(n / 1_000_000.0 * 100) / 100) + "M"
	elif n >= 1_000:
		return str(round(n / 1_000.0 * 100) / 100) + "K"
	else:
		return str(n)
