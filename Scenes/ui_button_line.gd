extends HBoxContainer

@export var plus_scene: PackedScene
@export var template_scene: PackedScene
@export var blue_button: Texture2D
@export var yellow_button: Texture2D
@export var red_button: Texture2D
@export var green_button: Texture2D
@export var lever_button: Texture2D

func set_ingredients_textures(combinaison: Array) -> void:
	for index in range(0, combinaison.size()):
		if index != 0:
			add_plus()
		match combinaison[index]:
			0:
				add_image(blue_button)
			1:
				add_image(red_button)
			2:
				add_image(lever_button)
			3:
				add_image(green_button)
			4:
				add_image(yellow_button)

func add_image(texture: Texture2D) -> void:
	var img = template_scene.instantiate() as TextureRect
	img.texture = texture
	call_deferred("add_child", img)

func add_plus() -> void:
	var plus = plus_scene.instantiate()
	call_deferred("add_child", plus)
