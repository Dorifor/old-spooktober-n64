extends CharacterBody3D


var SPEED = 2.0
const JUMP_VELOCITY = 1.5

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var walking_speed = 0.1
@export var run_speed = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		$visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		$Camera_mount.rotate_x((deg_to_rad(-event.relative.y * sens_vertical)))

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
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		$visuals.look_at(position + direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	

