class_name Player
extends CharacterBody3D


const JUMP_VELOCITY = 4.5

@export_category('Movement')
@export var movement_speed: float = 5.0
@export var sprint_speed: float = 8.5

@export_category('Camera')
@export var mouse_sensitivity: float = 0.003
@export var head_bob_multiplier: float = 1.5

@onready var body: Node3D = $Body
@onready var head: Node3D = $Body/Head

@onready var camera: Camera3D = $Body/Head/Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed: float = movement_speed
var is_sprinting: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	reset_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed('escape'):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			body.rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(45))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('sprint'):
		speed = sprint_speed
		is_sprinting = true
	
	if event.is_action_released('sprint'):
		speed = movement_speed
		is_sprinting = false

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	jump()
	move()
	
	camera_settings()
	
	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func move() -> void:
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		


func reset_camera() -> void:
	camera.set_rotation_degrees(Vector3.ZERO)


func camera_settings() -> void:
	if is_sprinting:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(camera, 'fov', 82, 0.2)
	else:
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(camera, 'fov', 75, 0.2)
