extends Button
class_name ShellyLightButton

@export var device: ShellyPlus1PM

func _ready() -> void:
	text = "💡"
	add_theme_font_size_override("font_size", 48)

	custom_minimum_size = Vector2(80, 80)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.5, 0.5, 0.55)
	style.set_corner_radius_all(100)
	style.set_content_margin_all(16)
	add_theme_stylebox_override("normal", style)

	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.6, 0.6, 0.6, 0.7)
	add_theme_stylebox_override("hover", hover)

	var pressed_style := style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color(0.4, 0.4, 0.4, 0.8)
	add_theme_stylebox_override("pressed", pressed_style)

	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	pressed.connect(device.toggle)
	device.relais.connect(_update)

func _update(state: bool) -> void:
	modulate = Color.WHITE if state else Color(0.35, 0.35, 0.35)
