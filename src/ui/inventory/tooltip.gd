extends ColorRect
class_name Tooltip

@onready var margin_container: MarginContainer = $MarginContainer
@onready var item_name: Label = $MarginContainer/Label

func set_text(_text: String) -> void:
	self.item_name.text = _text
	margin_container.size = Vector2()
	size = margin_container.size
