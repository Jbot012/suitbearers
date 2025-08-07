extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5
const SMOOTH_SPEED = 10.0

@onready var animation_player: AnimationPlayer = $visuals/player/AnimationPlayer
@onready var visuals: Node3D = $visuals
@onready var camera_point: Node3D = $camera_point

var walking = false

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	GameManager.set_player(self)
	
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var visual_dir = Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		 
		visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(-visual_dir.x, -visual_dir.z), delta * SMOOTH_SPEED)
		
		if !walking:
			walking = true
			animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if walking:
			walking = false
			animation_player.play("idle")
	
	move_and_slide()
