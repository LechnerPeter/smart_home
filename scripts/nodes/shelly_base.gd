# shelly_base.gd
extends Node
class_name ShellyBase

enum State {
	ERROR,
	CONNECTING,
	READY
}

@export var IPAdress: String

var _ws := WebSocketPeer.new()

signal state(value: State)
var _state : State:
	set(value):
		_state = value
		state.emit(value)

signal ws_message(payload: Dictionary)

func _ready() -> void:
	_state = State.CONNECTING

	var err := _ws.connect_to_url("ws://%s/rpc" % IPAdress)
	if err != OK:
		_state = State.ERROR
		push_error("WebSocket connect error: %s" % err)
		return
	await _wait_for_ws_open()
	var err2 := _ws.send_text(Helpers.payload(self, "Shelly.GetStatus", {}))
	if err2 != OK:
		_state = State.ERROR
		push_error("WebSocket send error: %s" % err2)
	
func _wait_for_ws_open() -> void:
	while _ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		_ws.poll()
		await get_tree().process_frame

	if _ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		_state = State.ERROR
		push_error("WebSocket failed to open")


func _process(_delta: float) -> void:
	_ws.poll()
	var ws_state := _ws.get_ready_state()
	if ws_state == WebSocketPeer.STATE_OPEN:
		while _ws.get_available_packet_count() > 0:
			var packet := _ws.get_packet()
			var text := packet.get_string_from_utf8()
			var data = JSON.parse_string(text)
			if data == null: print("JSON parse failed")
			else: ws_message.emit(data)
	elif ws_state == WebSocketPeer.STATE_CLOSED:
		print("WebSocket closed. code=%s reason=%s" % [_ws.get_close_code(), _ws.get_close_reason()])
		set_process(false)
