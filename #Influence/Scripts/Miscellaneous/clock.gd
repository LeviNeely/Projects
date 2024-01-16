extends Label

var datetime: Dictionary
var weekday: String
var month: String
var day: String
var hour: String
var minute: String
var am: String
var pm: String
var final_text: String

func _ready() -> void:
	update_label(true)

func _process(_delta) -> void:
	update_label(false)

func update_label(start: bool) -> void:
	datetime = Time.get_datetime_dict_from_system()
	if start:
		weekday = number_to_datetime(0, datetime["weekday"])
		month = number_to_datetime(1, datetime["month"])
		day = number_to_datetime(2, datetime["day"])
		hour = number_to_datetime(3, datetime["hour"])
		minute = number_to_datetime(4, datetime["minute"])
		final_text = weekday + " " + month + " " + day + " " + hour + ":" + minute + am + pm
		text = final_text
	else:
		if datetime["second"] == 0:
			weekday = number_to_datetime(0, datetime["weekday"])
			month = number_to_datetime(1, datetime["month"])
			day = number_to_datetime(2, datetime["day"])
			hour = number_to_datetime(3, datetime["hour"])
			minute = number_to_datetime(4, datetime["minute"])
			final_text = weekday + " " + month + " " + day + " " + hour + ":" + minute + am + pm
			text = final_text

func number_to_datetime(type: int, value: int) -> String:
	match type:
		0:
			#Weekday
			match value:
				0:
					return "Sunday"
				1:
					return "Monday"
				2:
					return "Tuesday"
				3:
					return "Wednesday"
				4:
					return "Thursday"
				5:
					return "Friday"
				6:
					return "Saturday"
		1:
			#Month
			match value:
				1:
					return "January"
				2:
					return "February"
				3:
					return "March"
				4:
					return "April"
				5:
					return "May"
				6:
					return "June"
				7:
					return "July"
				8:
					return "August"
				9:
					return "September"
				10:
					return "October"
				11:
					return "November"
				12:
					return "December"
		2:
			#Day
			return str(value)
		3:
			#Hour
			if value == 0:
				am = "AM"
				pm = ""
				return "12"
			elif value == 24:
				am = ""
				pm = "PM"
				return "12"
			elif value > 12:
				am = ""
				pm = "PM"
				return str(value % 12)
			else:
				return str(value)
		4:
			#Minute
			return str(value)
	return "TIME:ERROR"
