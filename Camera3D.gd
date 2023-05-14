extends Camera3D

@export var player: Node3D

func _ready() -> void:
	assert(player, 'Missing player')


func _physics_process(delta: float) -> void:
	global_position = player.get_node('Marker3D').global_position
	global_rotation = player.get_node('Marker3D').global_rotation
