extends TextureButton

@onready var focus_sound: AudioStreamPlayer2D = $AudioStreamPlayer

func _ready():
	grab_focus()
	focus_mode = Control.FOCUS_ALL
	self.focus_entered.connect(_on_focus_entered)

func _on_focus_entered():
	if focus_sound and not focus_sound.playing:
		focus_sound.play()

func _unhandled_input(event):
	if event.is_action_pressed("ui_valider") and has_focus():
		emit_signal("pressed")
