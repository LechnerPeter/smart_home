extends Button
class_name ShellyLightButton

@export var raum : String
@export var shelly : String

@onready var switch = Helpers.get_shelly(raum, shelly) as ShellySwitch

func _ready() -> void:
	pressed.connect(switch.toggle)
