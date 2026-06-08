extends PointLight2D
class_name ShellyLight

@export var device: ShellyPlus1PM

func _ready() -> void:
	device.relais.connect(_change)

func _change(state: bool) -> void:
	enabled = state
