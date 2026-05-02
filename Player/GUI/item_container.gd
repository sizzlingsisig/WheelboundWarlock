extends TextureRect


var upgrade = null
var frame_size = Vector2(12, 12)

func _ready():
	if upgrade != null:
		var icon_path = UpgradeDb.UPGRADES[upgrade]["icon"]
		$ItemTexture.texture = load(icon_path)
		var tex = $ItemTexture.texture
		if tex:
			var frame_count = 1
			var icon_name = icon_path.get_file()
			if icon_name == "spark.png":
				frame_count = 8
				tex = tex.get_image()
				tex = tex.get_region(Rect2i(0, 0, tex.get_width() / frame_count, tex.get_height()))
				$ItemTexture.texture = ImageTexture.create_from_image(tex)
			var tex_size = $ItemTexture.texture.get_size()
			var scale_x = frame_size.x / tex_size.x
			var scale_y = frame_size.y / tex_size.y
			var scale_factor = min(scale_x, scale_y)
			$ItemTexture.scale = Vector2(scale_factor, scale_factor)
			var centered_offset = (frame_size - (tex_size * scale_factor)) / 2
			$ItemTexture.position = centered_offset
