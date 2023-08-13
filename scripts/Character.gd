extends CharacterBody3D


const SPEED = 5.0
const CROUCHSPEED = 2.0
const JUMP_VELOCITY = 4.5
@export var sensitivity = 3
var crouched : bool
var FlashLight : bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("Flashlight"):
		if !FlashLight:
			$AnimationPlayer.play("FlashlightOn")
			FlashLight = true
		else:
			$AnimationPlayer.play("Flashlightoff")
			FlashLight = false
			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("Crouch"):
		if !crouched:
			$AnimationPlayer.play("Crouch")
			crouched = true
			
		else:
			if crouched:
				var space_state = get_world_3d().direct_space_state
				var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0,2,0), 1, [self.get_rid()]))
				var result1 = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(.5,2,0), 1, [self.get_rid()]))
				var result2 = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0,2,.5), 1, [self.get_rid()]))
				var result3 = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(-.5,2,0), 1, [self.get_rid()]))
				var result4 = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0,2,-.5), 1, [self.get_rid()]))
				if result.size() == 0 and result1.size() == 0 and result2.size() == 0 and result3.size() == 0 and result4.size() == 0:
					crouched = false
					$AnimationPlayer.play("UnCrouch")
					

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if crouched == true:
			velocity.x = direction.x * CROUCHSPEED
			velocity.z = direction.z * CROUCHSPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if input_dir.x>0:
		$Camera3d.rotation.z = lerp_angle($Camera3d.rotation.z, deg_to_rad(-2), 0.05)
	elif input_dir.x<0:
		$Camera3d.rotation.z = lerp_angle($Camera3d.rotation.z, deg_to_rad(2), 0.05)
	else:
		$Camera3d.rotation.z = lerp_angle($Camera3d.rotation.z, deg_to_rad(0), 0.05)
		
func _input(event):
	if(event is InputEventMouseMotion):
		rotation.y -= event.relative.x / 1000 * sensitivity
		$Camera3d.rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.x = clamp(rotation.x, PI/-2, PI/2)
		$Camera3d.rotation.x = clamp($Camera3d.rotation.x, -2, 2)
