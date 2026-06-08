extends Node
class_name ShellyDoorWindow

@export var mac_address : String
@export var polling_interval : float = 1.0

var sum_delta = 0

@onready var base : ShellyBase = get_parent() as ShellyBase

signal open(value: bool)
var _open : bool:
	set(value):
		_open = value
		open.emit(value)

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
		if _open != (bytes[10] == 1): _open = bytes[10] == 1 
