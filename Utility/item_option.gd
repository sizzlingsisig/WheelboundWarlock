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
	_set_icon()
	_set_child_mouse_filter(self)

func _set_icon():
	var upgrade_data = UpgradeDb.UPGRADES[item]
	if upgrade_data.has("sprite_region") and upgrade_data.has("sprite_sheet"):
		var sheet = load(upgrade_data["sprite_sheet"])
		if sheet:
			var atlas = AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = upgrade_data["sprite_region"]
			itemIcon.texture = atlas
			_fit_icon_to_frame(itemIcon, true)
	elif upgrade_data.has("icon"):
		var icon_path = upgrade_data["icon"]
		itemIcon.texture = load(icon_path)
		_fit_icon_to_frame(itemIcon, false, icon_path)

func _fit_icon_to_frame(icon, is_spritesheet = false, icon_path = ""):
	if icon.texture:
		var frame_size = Vector2(24, 24)
		var tex = icon.texture
		if icon_path != "" and icon_path.get_file() == "spark.png":
			var img = tex.get_image()
			if img:
				var region_img = img.get_region(Rect2i(0, 0, img.get_width() / 8, img.get_height()))
				icon.texture = ImageTexture.create_from_image(region_img)
		var tex_size = icon.texture.get_size()
		var use_smaller = false
		if is_spritesheet:
			use_smaller = true
		elif icon_path != "":
			var icon_name = icon_path.get_file()
			if icon_name in ["ice_spear.png", "tornado.png", "lightningicon.png", "Dark-Bolt.png", "spark.png"]:
				use_smaller = true
		if use_smaller:
			var scale_factor = 0.5
			icon.scale = Vector2(scale_factor, scale_factor)
		else:
			var scale_x = frame_size.x / tex_size.x
			var scale_y = frame_size.y / tex_size.y
			var scale_factor = min(scale_x, scale_y) * 0.7
			icon.scale = Vector2(scale_factor, scale_factor)
		var scaled_size = tex_size * icon.scale.x
		var centered_offset = (frame_size - scaled_size) / 2
		if is_spritesheet:
			centered_offset += Vector2(-3, -3)
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
