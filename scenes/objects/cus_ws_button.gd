extends TextureButton

func _ready():
	pass

func _on_TextureButton_pressed():
	for i in get_parent().get_children():
		if i is TextureButton:
			i.get_node("Selected").visible = false
	$Selected.visible = true
