extends Control
class_name Inventory

var inventory_item_scene = preload("res://src/ui/inventory/inventory_item.tscn")

@export var rows: int = 3
@export var cols: int = 6

@export var inventory_grid: GridContainer

@export var inventory_slot_scene: PackedScene
var slots: Array[InventorySlot]

@export var tooltip: Tooltip # Must be shared among all instances

static var selected_item: Item = null

var rock = preload("res://src/items/rock.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	inventory_grid.columns = cols
	for i in range(rows * cols):
		var slot = inventory_slot_scene.instantiate()
		slots.append(slot)
		slot.slot_input.connect(self._on_slot_input)
		slot.slot_hovered.connect(self._on_slot_hovered)
	
	# Add slots to inventory grid in reverse row order so hotbar is 0-9
	for i in range(rows):
		for j in range(cols):
			inventory_grid.add_child(slots[(rows - i - 1) * cols + j])
	
	tooltip.visible = false
	
	hide()

func _process(_delta):
	tooltip.global_position = get_global_mouse_position() + Vector2.ONE * 8
	if selected_item:
		tooltip.visible = false
		selected_item.global_position = get_global_mouse_position()
	
	# Pause the game if inventory is visible
	get_tree().paused = self.visible

func _on_slot_input(which: InventorySlot, action: InventorySlot.InventorySlotAction):
	print(action)
	# Select/deselect items
	if not selected_item:
		# Splitting only occurs if ite not selected already
		if action == InventorySlot.InventorySlotAction.SELECT:
			selected_item = which.select_item()
		elif action == InventorySlot.InventorySlotAction.SPLIT:
			selected_item = which.split_item()
	else:
		selected_item = which.deselect_item(selected_item)

func _on_slot_hovered(which: InventorySlot, is_hovering: bool):
	if which.item:
		tooltip.set_text(which.item.item_name)
		tooltip.visible = is_hovering

# UI Input events
func _input(event):
	# Process UI events
	if event.is_action_pressed("ui_inventory"):
		visible = not visible
	if event.is_action_pressed("ui_close"):
		hide()
	if event.is_action_pressed("gimme_rock"):
		self.add_item(rock.instantiate(), 1)

# API::

# !DESTRUCTUVE (removes item itself from world  and adds its copy to inventory)
# Calling this func impies that item is not already in inventory
func add_item(item: Item, amount: int) -> void:
	var _item: InventoryItem = inventory_item_scene.instantiate()
	_item.set_data(item.item_name, item.icon, item.is_stackable, amount	)
	item.queue_free() # Consume the item by inventory (by end of frame)
	if item.is_stackable:
		for slot in slots:
			if slot.item and slot.item.item_name == _item.item_name:
				slot.item.amount += _item.amount
				return
	for slot in slots:
		if slot.item == null:
			slot.item = _item
			slot.update_slot()
			return


# !DESTRUCTUVE (removes from inventory if retrieved)
#A function to remove item from inventory and return if it exists
func retrieve_item(_item_name: String) -> Item:
	for i in range(slots.size()):
		if slots[i].item and slots[i].item.item_name == _item_name:
			return retrieve_index(i)
	return null

func retrieve_index(_item_index: int) -> Item:
	var slot = slots[_item_index]
	var copy_item := Item.new()
	copy_item.item_name = slot.item.item_name
	copy_item.name = copy_item.item_name
	copy_item.icon = slot.item.icon
	copy_item.is_stackable = slot.item.is_stackable
	if slot.item.amount > 1:
		slot.item.amount -= 1
	else:
		slot.remove_item()
	return copy_item

# !NON-DESTRUCTIVE (read-only function) to get all items in inventory
func all_items() -> Array[Item]:
	var items: Array[Item] = []
	for slot in slots:
		if slot.item:
			items.append(slot.item)
	return items

# ! NON-DESTRUCTUVE (read-only), returns all items of a particular type
func all(_name: String) -> Array[Item]:
	var items: Array[Item] = []
	for slot in slots:
		if slot.item and slot.item.item_name == _name:
			items.append(slot.item)
	return items

# !DESTRUCTUVE (removes all items of a particular type)
func remove_all(_name: String) -> void:
	for slot in slots:
		if slot.item and slot.item.item_name == _name:
			slot.remove_item()

# !DESTRUCTUVE (removes all items from inventory)
func clear_inventory() -> void:
	for slot in slots:
		slot.remove_item()

func get_hotbar() -> Array[InventorySlot]:
	return slots.slice(0,10)
