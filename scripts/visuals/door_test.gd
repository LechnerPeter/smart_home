extends TileMapLayer
class_name ShellyTiles

@export var raum : String
@export var shelly : String
@export var door : String

@onready var sensor = Helpers.get_shelly_blu(raum, shelly, door) as ShellyDoorWindow

func _ready() -> void:
	sensor.open.connect(_parse)

func _parse(on : bool) -> void:
	visible = on
