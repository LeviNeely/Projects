extends Node

func determine_money_amount(money: float) -> String:
	if money <= 999999.99:
		return "%.2f" % money
	else:
		var exponent: int = 0
		while money >= 10.0:
			money /= 10.0
			exponent += 1
		var mantissa: float = snapped(money, 0.01)
		return "%.2fe%d" % [mantissa, exponent]
