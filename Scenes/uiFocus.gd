extends TextureButton

@onready var focus_sound: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	grab_focus()
	focus_mode = Control.FOCUS_ALL
	self.focus_entered.connect(_on_focus_entered)

func _on_focus_entered():
	if focus_sound and not focus_sound.playing:
		focus_sound.play()
