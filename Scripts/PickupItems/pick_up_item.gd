extends RigidBody3D
class_name PickUpItem

var last_position := Vector3.ZERO
var target_position := Vector3.ZERO
var lerp_alpha := 0.0
@export var item: ResPickableItem
@export var mesh: MeshInstance3D
@export var outline_thickness: float
var mesh_outline_shader: ShaderMaterial
var original_position := Vector3.ZERO
var recipe_manager: RecipeManager
var is_reseting := false
var player: Player


func _ready() -> void:
	recipe_manager = get_parent().get_parent()
	original_position = global_transform.origin
	mesh_outline_shader = mesh.material_overlay as ShaderMaterial
	
@rpc("any_peer")
func update_item_position(new_pos: Vector3):
	last_position = global_transform.origin
	target_position = new_pos
	lerp_alpha = 0.0

@rpc("any_peer", "call_local")
func _set_multiplayer_authority(id: int):
	set_multiplayer_authority(id)

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		update_item_position.rpc(global_transform.origin)
	else:
		lerp_alpha = min(lerp_alpha + delta * 5.0, 1)
		global_transform.origin = last_position.lerp(target_position, lerp_alpha)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("cauldron") and player and ChallengeManager.can_complete_challenge(player.name.to_int()):
		linear_velocity = Vector3.ZERO
		player.release_item()
		is_reseting = true
		recipe_manager.try_ingredient(item)
		respawn_item_rpc.rpc()
		_reset_item()

@rpc("any_peer", "call_local")
func respawn_item_rpc() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.2)
	tween.tween_callback(func():
		global_transform.origin = original_position
		if is_multiplayer_authority():
			update_item_position.rpc(original_position)
			var scale_up_tween = create_tween()
			scale_up_tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.2)
	)
	
@rpc("any_peer")
func scale_down_and_queue_free_rpc() -> void:
	scale_down_and_queue_free()

func scale_down_and_queue_free() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.2)
	tween.tween_callback(make_item_respawn)

func make_item_respawn() -> void:
	var tween = create_tween()
	global_transform.origin = original_position
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.2)

func _reset_item() -> void:
	await get_tree().create_timer(4).timeout
	is_reseting = false
	
func activate_outline() -> void:
	if mesh_outline_shader:
		mesh_outline_shader.set_shader_parameter("thickness", outline_thickness)

func deactivate_outline() -> void:
	if mesh_outline_shader:
		mesh_outline_shader.set_shader_parameter("thickness", 0.0)
