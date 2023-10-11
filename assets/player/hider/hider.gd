extends CharacterBody3D

var is_focusing_prop: bool = false
var focused_prop: StaticBody3D = null
var is_short: bool = false
var is_ability_available: bool = true

var speed_factor = 1
var scale_factor = 1
var camera_long_distance = 3

@export var walking_speed = 2
@export var run_speed = 4
@export var jump_velocity = 2.3

@export var rig: Node3D
@export var camera_mount: Node3D
@export var camera: Camera3D
@export var raycast: RayCast3D
@export var ability_timer: Timer
@export var ability_cooldown_timer: Timer

@export var hider_mesh: MeshInstance3D
@export var hider_collision: CollisionShape3D

# To set in map scene / by code
@export var pause_menu: Control
@export var interact_ui: Control

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
	
	if is_focusing_prop and event is InputEventKey and event.is_action_pressed("interact"):
		transform_into_prop()
		disable_power(true)
	
	if event is InputEventKey and event.is_action("shortening") and not is_short and is_ability_available:
		activate_power()


func transform_into_prop():
	var focused_mesh: MeshInstance3D = focused_prop.get_node("Mesh")
	var focused_collision: CollisionShape3D = focused_prop.get_node("Collision")
	hider_mesh.mesh = focused_mesh.mesh
	hider_mesh.position.y = focused_mesh.position.y
	hider_collision.shape = focused_collision.shape
	hider_collision.position.y = focused_collision.position.y
	scale = focused_prop.scale
	position.y = focused_prop.position.y


func activate_power():
	is_short = true
	scale /= 2
	speed_factor = 3
	camera.position.y += 3
	camera.position.z += 3
	is_ability_available = false
	ability_timer.start()


func disable_power(just_transformed: bool = false):
	if not is_short: return
	ability_timer.stop()
	ability_cooldown_timer.start()
	is_short = false
	speed_factor = 1
	camera.position.y -= 3
	camera.position.z -= 3
	if just_transformed: return
	scale *= 2


func _process(_delta):
	interact_ui.visible = raycast.is_colliding()
	is_focusing_prop = raycast.is_colliding()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		focused_prop = collider


func _physics_process(delta):
	var speed: float
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walking_speed
	speed *= speed_factor
	
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
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		rig.look_at(position + -direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func pause():
	Globals.IS_GAME_PAUSED = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.visible = true
	get_tree().paused = true


func _on_ability_timer_timeout():
	disable_power()


func _on_ability_cooldown_timeout():
	is_ability_available = true
