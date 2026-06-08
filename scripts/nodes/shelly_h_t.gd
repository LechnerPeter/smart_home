extends Node
class_name ShellyHumidityTemperatur

@export var mac_address : String
@export var polling_interval : float = 1.0

var sum_delta = 0

@onready var base : ShellyBase = get_parent() as ShellyBase

signal temperature(value: int)
var _temperature : int:
	set(value):
		_temperature = value
		temperature.emit(value)

signal humidity(value: int)
var _humidity : int:
	set(value):
		_humidity = value
		humidity.emit(value)

func _ready() -> void:
	base.ws_message.connect(_parse)

func _process(delta: float) -> void:
	if base._ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		sum_delta += delta
		if sum_delta > polling_interval:
			sum_delta = 0
			base._ws.send_text(Helpers.payload(self, "BLE.CloudRelay.ListInfos", {}))

func _parse(payload : Dictionary) -> void:
	var hex = Helpers.deep_get(payload, ["result", "devices", 0, mac_address, "sdata", "fcd2"])
	if hex != null:
		var bytes: PackedByteArray = Marshalls.base64_to_raw(hex)
		_humidity = bytes[6]
		_temperature = bytes[8]
