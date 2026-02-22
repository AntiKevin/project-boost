extends RigidBody3D

# Magnitude da força de movimentação do player
@export_range(100, 3000) var movement_mag: float = 1000
# Magnitude da força de rotação do player
@export_range(100, 3000) var rotation_mag: float = 500

var is_transitioning: bool = false

func boost(delta):
	apply_central_force(basis.y * delta * movement_mag)

func rotate_right(delta):
	apply_torque(Vector3.FORWARD * delta * rotation_mag)

func rotate_left(delta):
	apply_torque(Vector3.BACK * delta * rotation_mag)

func crash_sequence() -> void:
	is_transitioning = true
	print('Kaboom!')
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(get_tree().reload_current_scene)
	set_process(false)
	
func complete_level(next_level_file_path: String) -> void:
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file_path)
	)
	set_process(false)
	

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed('boost'):
		boost(delta)
	
	if Input.is_action_pressed('rotate_right'):
		rotate_right(delta)
	
	if Input.is_action_pressed('rotate_left'):
		rotate_left(delta)


func _on_body_entered(body: Node) -> void:
	if !is_transitioning:
		if 'Goals' in body.get_groups():
			var next_level_file_path: String = body.file_path
			complete_level(next_level_file_path)
		if 'Hazard' in body.get_groups():
			crash_sequence()
