
# These functions are the same as the ones found in the GDNative library.
# They are used if the user's platform is not supported.

const Util = preload("../util/util.gd")


static func get_red_range(im: Image, rect: Rect2) -> Vector2:
	rect = rect.clip(Rect2(0, 0, im.get_width(), im.get_height()))
	var min_x := int(rect.position.x)
	var min_y := int(rect.position.y)
	var max_x := min_x + int(rect.size.x)
	var max_y := min_y + int(rect.size.y)

	im.lock()

	var min_height := im.get_pixel(min_x, min_y).r
	var max_height := min_height

	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var h = im.get_pixel(x, y).r
			if h < min_height:
				min_height = h
			elif h > max_height:
				max_height = h

	im.unlock()
	
	return Vector2(min_height, max_height)


static func get_red_sum(im: Image, rect: Rect2) -> float:
	rect = rect.clip(Rect2(0, 0, im.get_width(), im.get_height()))
	var min_x := int(rect.position.x)
	var min_y := int(rect.position.y)
	var max_x := min_x + int(rect.size.x)
	var max_y := min_y + int(rect.size.y)

	var sum := 0.0
	
	im.lock()

	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			sum += im.get_pixel(x, y).r

	im.unlock()
	
	return sum


static func get_red_sum_weighted(im: Image, brush: Image, pos: Vector2, 
	var factor: float) -> float:
		
	var min_x = int(pos.x)
	var min_y = int(pos.y)
	var max_x = min_x + brush.get_width()
	var max_y = min_y + brush.get_height()
	var min_noclamp_x = min_x
	var min_noclamp_y = min_y

	min_x = Util.clamp_int(min_x, 0, im.get_width())
	min_y = Util.clamp_int(min_y, 0, im.get_height())
	max_x = Util.clamp_int(max_x, 0, im.get_width())
	max_y = Util.clamp_int(max_y, 0, im.get_height())

	var sum = 0.0

	im.lock()
	brush.lock()

	for y in range(min_y, max_y):
		var by = y - min_noclamp_y

		for x in range(min_x, max_x):
			var bx = x - min_noclamp_x
			
			var shape_value = brush.get_pixel(bx, by).r
			sum += im.get_pixel(x, y).r * shape_value * factor

	im.lock()
	brush.unlock()
	
	return sum


static func add_red_brush(im: Image, brush: Image, pos: Vector2, var factor: float):
	var min_x = int(pos.x)
	var min_y = int(pos.y)
	var max_x = min_x + brush.get_width()
	var max_y = min_y + brush.get_height()
	var min_noclamp_x = min_x
	var min_noclamp_y = min_y

	min_x = Util.clamp_int(min_x, 0, im.get_width())
	min_y = Util.clamp_int(min_y, 0, im.get_height())
	max_x = Util.clamp_int(max_x, 0, im.get_width())
	max_y = Util.clamp_int(max_y, 0, im.get_height())

	im.lock()
	brush.lock()

	for y in range(min_y, max_y):
		var by = y - min_noclamp_y

		for x in range(min_x, max_x):
			var bx = x - min_noclamp_x

			var shape_value = brush.get_pixel(bx, by).r
			var r = im.get_pixel(x, y).r + shape_value * factor
			im.set_pixel(x, y, Color(r, r, r))

	im.lock()
	brush.unlock()


static func lerp_channel_brush(im: Image, brush: Image, pos: Vector2, 
	factor: float, target_value: float, channel: int):
		
	var min_x = int(pos.x)
	var min_y = int(pos.y)
	var max_x = min_x + brush.get_width()
	var max_y = min_y + brush.get_height()
	var min_noclamp_x = min_x
	var min_noclamp_y = min_y

	min_x = Util.clamp_int(min_x, 0, im.get_width())
	min_y = Util.clamp_int(min_y, 0, im.get_height())
	max_x = Util.clamp_int(max_x, 0, im.get_width())
	max_y = Util.clamp_int(max_y, 0, im.get_height())

	im.lock()
	brush.lock()

	for y in range(min_y, max_y):
		var by = y - min_noclamp_y

		for x in range(min_x, max_x):
			var bx = x - min_noclamp_x

			var shape_value = brush.get_pixel(bx, by).r
			var c = im.get_pixel(x, y)
			c[channel] = lerp(c[channel], target_value, shape_value * factor)
			im.set_pixel(x, y, c)

	im.lock()
	brush.unlock()


static func lerp_color_brush(im: Image, brush: Image, pos: Vector2, 
	factor: float, target_value: Color):
		
	var min_x = int(pos.x)
	var min_y = int(pos.y)
	var max_x = min_x + brush.get_width()
	var max_y = min_y + brush.get_height()
	var min_noclamp_x = min_x
	var min_noclamp_y = min_y

	min_x = Util.clamp_int(min_x, 0, im.get_width())
	min_y = Util.clamp_int(min_y, 0, im.get_height())
	max_x = Util.clamp_int(max_x, 0, im.get_width())
	max_y = Util.clamp_int(max_y, 0, im.get_height())

	im.lock()
	brush.lock()

	for y in range(min_y, max_y):
		var by = y - min_noclamp_y

		for x in range(min_x, max_x):
			var bx = x - min_noclamp_x

			var shape_value = brush.get_pixel(bx, by).r
			var c = im.get_pixel(x, y).linear_interpolate(target_value, factor * shape_value)
			im.set_pixel(x, y, c)

	im.lock()
	brush.unlock()


static func generate_gaussian_brush(im: Image) -> float:
	var sum := 0.0
	var center := Vector2(im.get_width() / 2, im.get_height() / 2)
	var radius := min(im.get_width(), im.get_height()) / 2.0

	im.lock()

	for y in im.get_height():
		for x in im.get_width():
			var d := Vector2(x, y).distance_to(center) / radius
			var v := clamp(1.0 - d * d * d, 0.0, 1.0)
			im.set_pixel(x, y, Color(v, v, v))
			sum += v;

	im.unlock()
	return sum
