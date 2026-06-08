extends PointLight2D
class_name ShellyLight

@export var raum : String
@export var shelly : String

@onready var switch = Helpers.get_shelly(raum, shelly) as ShellySwitch

func _ready() -> void:
	switch.relais.connect(_change)

func _change(state :bool) -> void:
	enabled = state
