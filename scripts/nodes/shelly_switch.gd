# shelly_switch.gd
extends ShellyBase
class_name ShellySwitch


signal relais(value: bool)

var _relais : bool:
	set(value):
		_relais = value
		relais.emit(value)

func _ready() -> void:
	super._ready()
	ws_message.connect(_parse)

func _parse(payload : Dictionary) -> void:	
	for key in ["params", "result"]:	
		var enabled = Helpers.deep_get(payload, [key, "switch:0", "output"])
		if enabled != null: _relais = enabled

func toggle() -> void:
	_ws.send_text(Helpers.payload(self, "Switch.Toggle", {"id":0}))
