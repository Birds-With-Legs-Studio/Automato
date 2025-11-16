extends Control
class_name Hotbar

var slots: Array[CenterContainer]

var inventory_item_scene: PackedScene = preload("res://src/ui/inventory/inventory_item.tscn")
@export var inventory: Inventory

@export var cols: int = 10

var selected: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for i in range(cols):
		slots.append(self.get_child(0).get_child(i))
		slots[i].get_child(0).toggle_mode = true
	
	select_slot(0)
	slots[0].get_child(0).button_pressed = true
	
	update()

func _process(_delta: float) -> void:
	self.visible = not inventory.visible

func update() -> void:
	var hotbar_items: Array[Item] = inventory.get_hotbar()
	for i in range(slots.size()):
		if slots[i].get_child_count() > 1:
			if slots[i].get_child(1) != hotbar_items[i]:
				slots[i].get_child(1).free()
				if hotbar_items[i] != null:
					slots[i].add_child((hotbar_items[i].duplicate()))
			
		else:
			if hotbar_items[i] != null:
				slots[i].add_child((hotbar_items[i].duplicate()))

func select_slot(i: int) -> void:
	slots[selected].get_child(0).button_pressed = false
	selected = i
	slots[selected].get_child(0).button_pressed = true

func _on_texture_button_pressed0() -> void:
	select_slot(0)

func _on_texture_button_pressed1() -> void:
	select_slot(1)

func _on_texture_button_pressed2() -> void:
	select_slot(2)

func _on_texture_button_pressed3() -> void:
	select_slot(3)

func _on_texture_button_pressed4() -> void:
	select_slot(4)

func _on_texture_button_pressed5() -> void:
	select_slot(5)

func _on_texture_button_pressed6() -> void:
	select_slot(6)

func _on_texture_button_pressed7() -> void:
	select_slot(7)

func _on_texture_button_pressed8() -> void:
	select_slot(8)

func _on_texture_button_pressed9() -> void:
	select_slot(9)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_slot((selected - 1) % 9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_slot((selected + 1) % 9)

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: select_slot(0)
			KEY_2: select_slot(1)
			KEY_3: select_slot(2)
			KEY_4: select_slot(3)
			KEY_5: select_slot(4)
			KEY_6: select_slot(5)
			KEY_7: select_slot(6)
			KEY_8: select_slot(7)
			KEY_9: select_slot(8)
			KEY_0: select_slot(9)
