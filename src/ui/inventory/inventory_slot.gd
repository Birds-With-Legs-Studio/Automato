extends Control
class_name InventorySlot

# So its copy can be instanced while splitting
@export var inventory_item_scene: PackedScene = preload("res://src/ui/inventory/inventory_item.tscn")

@export var item: InventoryItem

#hint_item restricts slot to only accept item of type hint_item??

enum InventorySlotAction {
	SELECT, SPLIT, # for item selection
}

signal slot_input(which: InventorySlot, action: InventorySlotAction)
signal slot_hovered(which: InventorySlot, is_hovering:bool)

func _ready():
	add_to_group("inventory_slots")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_texture_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_input.emit(self, InventorySlotAction.SELECT)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_input.emit(self, InventorySlotAction.SPLIT)


func _on_texture_button_mouse_entered() -> void:
	slot_hovered.emit(self, true)


func _on_texture_button_mouse_exited() -> void:
	slot_hovered.emit(self, false)

# TODO remove if unused
func remove_item():
	self.remove_child(item)
	item.free()
	item = null
	update_slot()

# Removes item from slot and returns it
func select_item() -> InventoryItem:
	var inventory = self.get_parent().get_parent() # Inventory
	var tmp_item := self.item
	if tmp_item:
		tmp_item.reparent(inventory)
		self.item = null
		tmp_item.z_index = 128
	# Show it above other items
	return tmp_item

# If swap, then return swapped item, else return null and add new item
func deselect_item(new_item: InventoryItem) -> InventoryItem:
	var inventory = self.get_parent().get_parent() # Inventory
	if self.item == null:
		new_item.reparent(self)
		self.item = new_item
		self.item.z_index = 64
		return null
	else:
		if new_item.item_name == self.item.item_name: # if both items are same
			self.item.amount += new_item.amount
			new_item.free()
			return null
		else: #if different type, swap
			new_item.reparent(self) # Make new thing our child
			self.item.reparent(inventory) # Make old thing inventory's child
			var tmp_item = self.item
			self.item = new_item
			new_item.z_index = 64 # Reset its z index????
			tmp_item.z_index = 128 # Update swapped item's z index
			return tmp_item

# Split means selecting half amount
func split_item() -> InventoryItem:
	if self.item == null:
		return null
	var inventory = self.get_parent().get_parent() # Inventory
	if self.item.amount > 1:
		var new_item: InventoryItem = inventory_item_scene.instantiate()
		new_item.set_data(
			self.item.item_name, self.item.icon,
			self.item.is_stackable, self.item.amount
		) # Because .duplicate() is buggy (doesn't make it unique)
		@warning_ignore("integer_division")
		new_item.amount = self.item.amount / 2
		self.item.amount -= new_item.amount
		inventory.add_child(new_item)
		new_item.z_index = 128
		return new_item
	elif self.item.amount == 1:
		return self.select_item()
	else:
		return null

func update_slot():
	if item:
		if not self.get_children().has(item):
			add_child(item)
		if item.amount < 1:
			item.fade()
