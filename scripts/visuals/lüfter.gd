extends VSlider
class_name ShellyLüfter

@export var raum : String
@export var shelly : String

@onready var dimmer = Helpers.get_shelly(raum, shelly) as ShellyDimmer

func _ready() -> void:
	dimmer.dimmer.connect(_change)
	drag_ended.connect(_changed)

func _change(payload : float) -> void:
	value = payload
	editable = true

func _changed(_ended : bool) -> void:
	editable = false
	dimmer.set_brightness(round(value))
