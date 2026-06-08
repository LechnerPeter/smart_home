# shelly_plus1pm.gd
extends Node
class_name ShellyPlus1PM

const SECRETS_PATH := "res://secrets.cfg"

@export var device_id: String = ""

var _ha_url: String
var _ha_token: String
var _ws := WebSocketPeer.new()
var _next_id := 1

signal relais(value: bool)
var _relais: bool:
	set(value):
		_relais = value
		relais.emit(value)

signal apower(value: float)
var _apower: float:
	set(value):
		_apower = value
		apower.emit(value)

signal voltage(value: float)
var _voltage: float:
	set(value):
		_voltage = value
		voltage.emit(value)

signal current(value: float)
var _current: float:
	set(value):
		_current = value
		current.emit(value)

signal total_energy(value: float)
var _total_energy: float:
	set(value):
		_total_energy = value
		total_energy.emit(value)

signal temperature(value: float)
var _temperature: float:
	set(value):
		_temperature = value
		temperature.emit(value)

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SECRETS_PATH) != OK:
		push_error("ShellyPlus1PM [%s]: could not load secrets.cfg" % device_id)
		return
	_ha_url = cfg.get_value("home_assistant", "url", "")
	_ha_token = cfg.get_value("home_assistant", "token", "")
	if _ha_url.is_empty() or _ha_token.is_empty():
		push_error("ShellyPlus1PM [%s]: url or token missing in secrets.cfg" % device_id)
		return

	var ws_url := _ha_url.replace("http://", "ws://").replace("https://", "wss://") + "/api/websocket"
	var err := _ws.connect_to_url(ws_url)
	if err != OK:
		push_error("ShellyPlus1PM [%s]: WebSocket connect error %d" % [device_id, err])

func _process(_delta: float) -> void:
	_ws.poll()
	while _ws.get_available_packet_count() > 0:
		var text := _ws.get_packet().get_string_from_utf8()
		var msg: Variant = JSON.parse_string(text)
		if msg is Dictionary:
			_handle_message(msg)

func _handle_message(msg: Dictionary) -> void:
	match msg.get("type", ""):
		"auth_required":
			_send({"type": "auth", "access_token": _ha_token})
		"auth_ok":
			_send({"id": _msg_id(), "type": "get_states"})
			_send({"id": _msg_id(), "type": "subscribe_events", "event_type": "state_changed"})
		"auth_invalid":
			push_error("ShellyPlus1PM [%s]: HA authentication failed" % device_id)
		"result":
			var result: Variant = msg.get("result")
			if result is Array:
				for state: Variant in result:
					if state is Dictionary:
						_apply_state(state.get("entity_id", ""), state)
		"event":
			var data: Dictionary = Helpers.deep_get(msg, ["event", "data"], {})
			_apply_state(data.get("entity_id", ""), data.get("new_state", {}))

func _apply_state(entity_id: String, state: Dictionary) -> void:
	if entity_id.is_empty() or state.is_empty():
		return
	var value: String = state.get("state", "")
	if entity_id == "switch." + device_id:
		_relais = value == "on"
	elif entity_id == "sensor." + device_id + "_power":
		_apower = float(value)
	elif entity_id == "sensor." + device_id + "_voltage":
		_voltage = float(value)
	elif entity_id == "sensor." + device_id + "_current":
		_current = float(value)
	elif entity_id == "sensor." + device_id + "_energy":
		_total_energy = float(value)
	elif entity_id == "sensor." + device_id + "_device_temperature":
		_temperature = float(value)

func turn_on() -> void:
	_call_service("turn_on")

func turn_off() -> void:
	_call_service("turn_off")

func toggle() -> void:
	_call_service("toggle")

func _call_service(service: String) -> void:
	_send({
		"id": _msg_id(),
		"type": "call_service",
		"domain": "switch",
		"service": service,
		"service_data": {"entity_id": "switch." + device_id}
	})

func _send(payload: Dictionary) -> void:
	_ws.send_text(JSON.stringify(payload))

func _msg_id() -> int:
	var id := _next_id
	_next_id += 1
	return id
