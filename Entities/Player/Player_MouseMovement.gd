extends CharacterBody3D

@export_category('Movement')
@export var raycast_length: int = 40
@export var move_speed: int = 8

@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var body: MeshInstance3D = $Body

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed('move'):
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		
		# Create Raycast
		var from: Vector3 = camera.project_ray_origin(mouse_pos)
		var to: Vector3 = from + (camera.project_ray_normal(mouse_pos) * raycast_length)
		
		# Create RayQuery
		var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		
		ray_query.set_from(from)
		ray_query.set_to(to)
		
		
		# Get Raycast result
		var result := space.intersect_ray(ray_query)
		#print(result)
		
		if result.has('position'):
			nav_agent.set_target_position(result.position)


func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	move_to_point()


func move_to_point() -> void:
	var target_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_pos)
	
	face_direction(target_pos)
	
	velocity = direction * move_speed
	nav_agent.set_velocity(velocity)
	
	move_and_slide()


func face_direction(direction: Vector3) -> void:
	# In Godot, forward is -Z
	body.look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)


func raycast_from_camera() -> void:
	pass
