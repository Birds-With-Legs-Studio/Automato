extends Item
class_name InventoryItem

# NOTE: IT IS not SLOT AMOUNT, but currently carried amount
@export var amount: int = 0

@export var sprite: Sprite2D
@export var label: Label


func set_data(_name: String, _icon: Texture2D, _is_stackable: bool, _amount: int):
	self.item_name = _name
	self.name = _name
	self.icon = _icon
	self.is_stackable = _is_stackable
	self.amount = _amount

func _process(_delta):
	self.sprite.texture = self.icon
	self.set_sprite_size_to(sprite, Vector2(42,42))
	if is_stackable:
		self.label.text = str(self.amount)
	else:
		label.visible = false

func set_sprite_size_to(sprite: Sprite2D, size: Vector2):
	var texture_size = sprite.texture.get_size()
	var scale_factor = size / texture_size / 8
	self.scale = scale_factor
