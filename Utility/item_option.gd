extends ColorRect

@onready var lblName = $lbl_name
@onready var lblDescription = $lbl_description
@onready var lblLevel = $lbl_level
@onready var itemIcon = $ColorRect/ItemIcon

var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade",Callable(player,"upgrade_character"))
	if item == null:
		item = "food"
	lblName.text = UpgradeDb.UPGRADES[item]["displayname"]
	lblDescription.text = UpgradeDb.UPGRADES[item]["details"]
	lblLevel.text = UpgradeDb.UPGRADES[item]["level"]
	var icon_path = UpgradeDb.UPGRADES[item]["icon"]
	itemIcon.texture = load(icon_path)
	_fit_icon_to_frame(itemIcon, icon_path)
	_set_child_mouse_filter(self)

func _fit_icon_to_frame(icon, icon_path):
	if icon.texture:
		var frame_size = Vector2(24, 24)
		var tex = icon.texture
		var frame_count = 1
		var icon_name = icon_path.get_file()
		if icon_name == "spark.png":
			frame_count = 8
			tex = tex.get_image()
			tex = tex.get_region(Rect2i(0, 0, tex.get_width() / frame_count, tex.get_height()))
			icon.texture = ImageTexture.create_from_image(tex)
		var tex_size = icon.texture.get_size()
		var scale_x = frame_size.x / tex_size.x
		var scale_y = frame_size.y / tex_size.y
		var scale_factor = min(scale_x, scale_y)
		icon.scale = Vector2(scale_factor, scale_factor)
		var centered_offset = (frame_size - (tex_size * scale_factor)) / 2
		icon.position = centered_offset

func _set_child_mouse_filter(node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_child_mouse_filter(child)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("selected_upgrade",item)
			accept_event()

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false
