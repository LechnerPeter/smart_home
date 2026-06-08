# home_assistant.gd
extends Node
class_name HomeAssistant

const SECRETS_PATH := "res://secrets.cfg"

var ha_url: String
var ha_token: String

func _ready() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SECRETS_PATH)
	if err != OK:
		push_error("HomeAssistant: could not load %s (error %d)" % [SECRETS_PATH, err])
		return
	ha_url = cfg.get_value("home_assistant", "url", "")
	ha_token = cfg.get_value("home_assistant", "token", "")
	if ha_url.is_empty() or ha_token.is_empty():
		push_error("HomeAssistant: url or token missing in secrets.cfg")
		return
	_request("/api/states", _on_states_received)

func _request(path: String, callback: Callable) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(callback)
	var err := http.request(ha_url + path, PackedStringArray([
		"Authorization: Bearer " + ha_token,
		"Content-Type: application/json"
	]))
	if err != OK:
		push_error("HomeAssistant: request to %s failed (error %d)" % [path, err])

func _on_states_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("HomeAssistant: /api/states failed (result=%d, code=%d)" % [result, response_code])
		return
	var states: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not states is Array:
		push_error("HomeAssistant: could not parse states")
		return
	var shelly_entities: Array = states.filter(
		func(s: Variant) -> bool:
			return s is Dictionary and "shelly" in s.get("entity_id", "").to_lower()
	)
	print("HomeAssistant: %d Shelly entities found" % shelly_entities.size())
	for entity: Dictionary in shelly_entities:
		var entity_id: String = entity.get("entity_id", "?")
		var state: String = entity.get("state", "?")
		var friendly_name: String = entity.get("attributes", {}).get("friendly_name", entity_id)
		print("  [%s] %s  →  %s" % [entity_id, friendly_name, state])
