extends HBoxContainer

@onready var number_rect: TextureRect = $Numero
@export var plus_scene: PackedScene
@export var template_scene: PackedScene
@export var pasteque_texture: Texture2D
@export var screw_texture: Texture2D
@export var bucket_texture: Texture2D
@export var pizza_texture: Texture2D

func set_ingredients_textures(ingredients: Array) -> void:
	for index in range(0, ingredients.size()):
		match ingredients[index].type:
			Enums.PICKABLE_ITEMS_TYPES.PASTEQUE:
				if index != 0:
					add_plus()
				add_image(pasteque_texture)
			Enums.PICKABLE_ITEMS_TYPES.SCREW:
				if index != 0:
					add_plus()
				add_image(screw_texture)
			Enums.PICKABLE_ITEMS_TYPES.BUCKET:
				if index != 0:
					add_plus()
				add_image(bucket_texture)
			Enums.PICKABLE_ITEMS_TYPES.PIZZA:
				if index != 0:
					add_plus()
				add_image(pizza_texture)

func add_image(texture: Texture2D) -> void:
	var img = template_scene.instantiate() as TextureRect
	img.texture = texture
	call_deferred("add_child", img)

func add_plus() -> void:
	var plus = plus_scene.instantiate()
	call_deferred("add_child", plus)
