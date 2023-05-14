extends VehicleBody3D

const STEER_LIMIT = 0.4
const STEER_SPEED = 1.5


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('reset'):
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	var steering_target = Input.get_axis('move_right', 'move_left')
	steering_target *= STEER_LIMIT
	
	steering = move_toward(steering, steering_target, STEER_SPEED * delta)
	
