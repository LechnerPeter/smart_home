extends Label
class_name show_temp_and_humid

@export var room : String
@export var shelly : String
@export var h_and_t : String

@onready var sensor = Helpers.get_shelly_blu(room, shelly, h_and_t) as ShellyHumidityTemperatur

func _ready() -> void:
	sensor.humidity.connect(_update)
	sensor.temperature.connect(_update)

func _update(_number) -> void:
	var temp : float = sensor._temperature / 10
	text = "Temperatur: %10s \n Humidity: %12s" % [temp, sensor._humidity] 
