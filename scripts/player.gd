extends RigidBody3D

@export_range(100, 3000) var movement_mag: float = 1000
@export_range(100, 3000) var rotation_mag: float = 500
@onready var death_sfx: AudioStreamPlayer = $DeathSFX
@onready var success_sfx: AudioStreamPlayer = $SuccessSFX
@onready var thrust_sfx: AudioStreamPlayer3D = $ThrustSFX

@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitioning: bool = false


func boost(delta):
	booster_particles.emitting = true
	right_booster_particles.emitting = true
	left_booster_particles.emitting = true
	if !thrust_sfx.playing:
			thrust_sfx.play()
	apply_central_force(basis.y * delta * movement_mag)
 
func stop_boost():
	thrust_sfx.stop()
	booster_particles.emitting = false
	right_booster_particles.emitting = false
	left_booster_particles.emitting = false

func rotate_right(delta):
	apply_torque(Vector3.FORWARD * delta * rotation_mag)
	left_booster_particles.emitting = false

func rotate_left(delta):
	apply_torque(Vector3.BACK * delta * rotation_mag)
	right_booster_particles.emitting = false

func crash_sequence() -> void:
	is_transitioning = true
	death_sfx.play()
	thrust_sfx.stop()
	booster_particles.emitting = false
	right_booster_particles.emitting = false
	left_booster_particles.emitting = false 
	explosion_particles.emitting = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	set_process(false)
	
func complete_level(next_level_file_path: String) -> void:
	is_transitioning = true
	success_sfx.play()
	booster_particles.emitting = false
	right_booster_particles.emitting = false
	left_booster_particles.emitting = false
	success_particles.emitting = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file_path)
	)
	set_process(false)
	

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed('boost'):
		boost(delta)
	else:
		stop_boost()	
	
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
