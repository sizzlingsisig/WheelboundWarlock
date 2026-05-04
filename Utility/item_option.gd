extends ColorRect

@onready var lblName: Label = $lbl_name
@onready var lblDescription: Label = $lbl_description
@onready var lblLevel: Label = $lbl_level
@onready var itemIcon: TextureRect = $ColorRect/ItemIcon

var mouse_over: bool = false
var item: String = ""
@onready var player: Node = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade: String)

func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	if item == "":
		item = "food"
	var upgrade_data = UpgradeDb.get_upgrade_data(item)
	if upgrade_data.is_empty():
		return
	lblName.text = upgrade_data["displayname"]
	lblDescription.text = upgrade_data["details"]
	lblLevel.text = upgrade_data["level"]
	_set_icon()
	_set_child_mouse_filter(self)

func _set_icon() -> void:
	var upgrade_data = UpgradeDb.get_upgrade_data(item)
	if upgrade_data.is_empty():
		return
	if upgrade_data.has("sprite_region") and upgrade_data.has("sprite_sheet"):
		var sheet_path = upgrade_data.get("sprite_sheet", "")
		if sheet_path.is_empty() or sheet_path == "res://":
			return
		var sheet = load(sheet_path)
		if sheet:
			var atlas = AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = upgrade_data["sprite_region"]
			itemIcon.texture = atlas
			_fit_icon_to_frame(itemIcon, true)
	elif upgrade_data.has("icon"):
		var icon_path = upgrade_data.get("icon", "")
		if icon_path.is_empty() or icon_path == "res://":
			return
		if ResourceLoader.exists(icon_path):
			itemIcon.texture = load(icon_path)
			_fit_icon_to_frame(itemIcon, false, icon_path)

func _fit_icon_to_frame(icon: TextureRect, is_spritesheet: bool = false, icon_path: String = "") -> void:
	if icon.texture:
		var frame_size: Vector2 = Vector2(24, 24)
		var tex = icon.texture
		if icon_path != "" and icon_path.get_file() == "spark.png":
			var img = tex.get_image()
			if img:
				var region_img = img.get_region(Rect2i(0, 0, img.get_width() / 8, img.get_height()))
				icon.texture = ImageTexture.create_from_image(region_img)
		var tex_size = icon.texture.get_size()
		var use_smaller: bool = false
		if is_spritesheet:
			use_smaller = true
		elif icon_path != "":
			var icon_name = icon_path.get_file()
			if icon_name in ["ice_spear.png", "tornado.png", "lightningicon.png", "Dark-Bolt.png", "spark.png"]:
				use_smaller = true
		if use_smaller:
			var scale_factor: float = 0.5
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

func _set_child_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_child_mouse_filter(child)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("selected_upgrade", item)
			accept_event()

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false