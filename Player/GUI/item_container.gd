extends TextureRect


var upgrade = null
var frame_size = Vector2(16, 16)
var border_color = Color(0.3, 0.3, 0.3, 1.0)
var bg_color = Color(0.0, 0.0, 0.0, 1.0)

func _ready():
	_connect_to_loaded()
	_apply_scaling()

func _connect_to_loaded():
	if upgrade != null:
		var upgrade_data = UpgradeDb.get_upgrade_data(upgrade)
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
				$ItemTexture.texture = atlas
		elif upgrade_data.has("icon"):
			var icon_path = upgrade_data.get("icon", "")
			if icon_path.is_empty() or icon_path == "res://":
				return
			if ResourceLoader.exists(icon_path):
				$ItemTexture.texture = load(icon_path)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, frame_size), bg_color, true)
	draw_rect(Rect2(Vector2.ZERO, frame_size), border_color, false, 1.0)

func _apply_scaling():
	custom_minimum_size = frame_size
	size = frame_size
	
	var tex = $ItemTexture.texture
	if tex:
		var tex_size = tex.get_size()
		if tex_size.x <= 0 or tex_size.y <= 0:
			tex_size = Vector2(16, 16)
		var scale_x = frame_size.x / tex_size.x
		var scale_y = frame_size.y / tex_size.y
		var scale_factor = min(scale_x, scale_y) * 0.7
		$ItemTexture.scale = Vector2(scale_factor, scale_factor)
		var centered_offset = (frame_size - (tex_size * scale_factor)) / 2
		$ItemTexture.position = centered_offset
