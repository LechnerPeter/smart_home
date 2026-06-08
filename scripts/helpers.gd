# helpers.gd
extends RefCounted
class_name Helpers

static func deep_get(root: Variant, keys: Array, default_value: Variant = null) -> Variant:
	if keys.is_empty():
		return root if root != null else default_value
	var k = keys[0]
	if k is int:
		if not root is Array or len(root) <= k:
			return default_value
		return deep_get(root[k], keys.slice(1), default_value)
	elif k is String:
		if not root is Dictionary or not root.has(k):
			return default_value
		return deep_get(root[k], keys.slice(1), default_value)
	assert(false, "Wrong type in deep_get")
	return default_value
