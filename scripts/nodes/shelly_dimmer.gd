# shelly_dimmer.gd
extends ShellyBase
class_name ShellyDimmer

signal relais(value: bool)
var _relais : bool:
	set(value):
		_relais = value
		relais.emit()

signal dimmer(value: float)
var _dimmer : float:
	set(value):
		_dimmer = value
		dimmer.emit(value)

func _ready() -> void:
	super._ready()
	ws_message.connect(_parse)

func _parse(payload : Dictionary) -> void:
	for key in ["params", "result"]:
		var enabled = Helpers.deep_get(payload, [key, "light:0", "output"])
		if enabled != null: _relais = enabled
		var dimm = Helpers.deep_get(payload, [key, "light:0", "brightness"])
		if dimm != null: _dimmer = dimm

func set_brightness(brightness : int) -> void:
	_ws.send_text(
		Helpers.payload(
			self,
			"Light.Set",{
				"id": 0,
				"on": true,
				"brightness": brightness
			}
		)
	)
