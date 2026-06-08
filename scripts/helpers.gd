# helpers.gd
extends RefCounted
class_name Helpers

static func get_shelly(raum: String, shelly: String) -> Node:
	print("/root/Main/Shelly/%s/%s" % [raum, shelly])
	return Engine.get_main_loop().root.get_node(
		"/root/Main/Shelly/%s/%s" % [raum, shelly]
	)
	
static func get_shelly_blu(raum: String, shelly: String, blu : String) -> Node:
	print("/root/Main/Shelly/%s/%s/%s" % [raum, shelly, blu])
	return Engine.get_main_loop().root.get_node(
		"/root/Main/Shelly/%s/%s/%s" % [raum, shelly, blu]
	)
	
static func payload(node : Node, method : String, params : Dictionary) -> String:
	var unique : String = str(node.get_path())
	return JSON.stringify({"id": unique,"src":unique,"method":method,"params": params})
	
static func deep_get(root, keys : Array, default_value:  Variant = null) -> Variant:
	if keys.is_empty():
		if root != null: return root 
		else: return default_value
	var k = keys[0]
	if k is int:
		if not root is Array: return default_value
		if len(root) <= k: return default_value
		var new_root = root[k]
		return deep_get(new_root, keys.slice(1) , default_value)
	elif k is String:
		if not root is Dictionary: return default_value
		if not root.has(k): return default_value
		var new_root = root[k]
		return deep_get(new_root, keys.slice(1) , default_value)
	else:
		assert(false, "Wrong type in deep_get")
	return default_value
