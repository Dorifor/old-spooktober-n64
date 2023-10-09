extends CharacterBody3D
class_name BasePlayer

var SPEED = 2.0

@export var walking_speed = 0.1
@export var run_speed = 2
@export var jump_velocity = 2.3

@export var rig: Node3D
@export var camera_mount: Node3D
@export var pause_menu: Control

var bulletPath = preload("res://assets/player/weapons/bullet.tscn")

@onready var animation_tree : AnimationTree = $visuals/Player/AnimationTree


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_tree.active = true

func _input(event):
	
	var horizontal_sens = Globals.HORIZONTAL_SENSIBILITY_VALUE
	var vertical_sens = Globals.VERTICAL_SENSIBILITY_VALUE 
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * horizontal_sens))
		rig.rotate_y(deg_to_rad(event.relative.x * horizontal_sens))
		
		camera_mount.rotate_x((deg_to_rad(-event.relative.y * vertical_sens)))
		var camera_rotation = camera_mount.rotation_degrees
		camera_rotation.x = clamp(camera_rotation.x, -30, 30)
		camera_mount.rotation_degrees = camera_rotation
		
	if event is InputEventKey and event.is_action("pause"):
		pause()

func _process(delta):
	update_animation_parameters()
	
	if Input.is_action_just_pressed("attack"):
		shoot()

func shoot():
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	bullet.position = $visuals/Player/LaunchPos.global_position
	bullet.transform.basis = $visuals/Player/LaunchPos.global_transform.basis
	get_parent().add_child(bullet)
	
	
func _physics_process(delta):
	if Input.is_action_pressed("run"):
		SPEED = run_speed
	else:
		SPEED = walking_speed
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		rig.look_at(position + -direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func pause():
	Globals.IS_GAME_PAUSED = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.visible = true
	get_tree().paused = true

func update_animation_parameters():
	var state_machine = animation_tree["parameters/playback"]
	if(velocity == Vector3.ZERO):
		state_machine.travel("Idle")
	else:
		state_machine.travel("Walk")
		if Input.is_action_pressed("run"):
			state_machine.travel("Run")
#	if Input.is_action_pressed("attack"):
#		state_machine.travel("Attack")
