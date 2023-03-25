extends Node3D


# значение на который будет изменяться угол/положение камеры
const dt: float = 0.1
# глобальный объект управляющий камерой
var camera: Rotator = null
# глобальный объект управляющий светом
var light: Rotator = null


# функция создания текстуры checker (гугли что за текстура такая)
func create_checker_texture() -> ImageTexture:
	# создаём наш холст
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	# заливаем его в чёрный цвет
	image.fill(Color.BLACK)
	# закрашиваем два квадрата белым цветом
	image.fill_rect(Rect2i(0, 0, 256, 256), Color.WHITE)
	image.fill_rect(Rect2i(256, 256, 256, 256), Color.WHITE)
	# генерим из картинки текстуру
	return ImageTexture.create_from_image(image)


func create_box(pos: Vector3, size: Vector3, color: Color):
	# создадим стандартный материал
	var box_material = StandardMaterial3D.new()
	# и зададим только цвет
	box_material.albedo_color = color
	
	# создадим меш коробки
	var box_mesh = BoxMesh.new()
	# и присвоим ему ранее созданный материал
	box_mesh.material = box_material
	
	# создадим MeshInstance
	var box_mesh_inst = MeshInstance3D.new()
	# поместим в него меш коробки
	box_mesh_inst.mesh = box_mesh
	# и зададим масштаб
	box_mesh_inst.scale = size
	
	# создадим ноду определения коллизии
	var box_collision = CollisionShape3D.new()
	# и выставим для него форму коробки
	box_collision.shape = BoxShape3D.new()
	# и также зададим масштаб
	box_collision.scale = size
	
	# остаётся только создать твёрдое тело
	var box_obj = RigidBody3D.new()
	# выставим ему позицию на сцене
	box_obj.position = pos
	# добавить коллизию
	box_obj.add_child(box_collision)
	# и меш
	box_obj.add_child(box_mesh_inst)
	
	# и можно возращать готовый объект
	return box_obj


func create_light(pos: Vector3) -> Light3D:
	# создаём источник света
	var object = OmniLight3D.new()
	# выставлдяем позицию
	object.position = pos
	# включаем поддержку теней
	object.shadow_enabled = true
	return object


func add_box_wall(x_count: int, y_count: int, start: Vector3, shift: Vector3, color: Color):
	var p = Vector3.ZERO
	# будем создавать коробки рядами
	for y in range(y_count):
		# выставим начально положение коробки по x
		p.x = start.x + (shift.x * 0.1)
		for x in range(x_count):
			# добавим созданную коробку сразу на сцену
			add_child(create_box(p, shift, color))
			# увеличим позицию по x
			p.x = start.x + shift.x * x
		# а после окончания цикла - по y
		p.y += shift.y * 1.01


func add_floor(size: Vector3):
	# создадим материал для нашего пола
	var floor_material = StandardMaterial3D.new()
	# альбедо - основной цвет
	floor_material.albedo_texture = create_checker_texture()
	# и увеличим число повторений текстуры
	floor_material.uv1_scale = 20 * Vector3(1, 1, 0)
	
	# cоздадим меш нашего пола в виде плоскости
	var floor_mesh = PlaneMesh.new()
	# добавим к нему ранее созданный материал
	floor_mesh.material = floor_material
	
	# и завернём наш меш в MeshInstance
	var floor_mesh_inst = MeshInstance3D.new()
	# сюда масштаб меша запишем
	floor_mesh_inst.scale = size
	# и сам меш
	floor_mesh_inst.mesh = floor_mesh
	
	# создадим ноду определения коллизии
	var floor_collision = CollisionShape3D.new()
	# и выставим форму коллизии в виде бесконечной плоскости
	floor_collision.shape = WorldBoundaryShape3D.new()
	
	# теперь же остаётся создать статический объект
	var floor_obj = StaticBody3D.new()
	# добавить в него ноду коллизии
	floor_obj.add_child(floor_collision)
	# меш
	floor_obj.add_child(floor_mesh_inst)
	
	# и можно добавлять на сцену
	add_child(floor_obj)


func add_camera():
	# создаём ноду управляющую камерой
	camera = Rotator.new(90, 3, 1)
	# создаём ноду самой камеры
	var cam_obj = Camera3D.new()
	# делаем камеру главной
	cam_obj.make_current()
	# добавляем её к управляющему объекту
	camera.add_child(cam_obj)
	# добавляем на сцену
	add_child(camera)


func add_light():
	# обойдёмся несколькими неподвижными источниками света
	add_child(create_light(Vector3(-1.5, 1, 2)))
	add_child(create_light(Vector3(1.5, 1, 2)))
	
	# и одним перемещаемым
	light = Rotator.new(0, 1, 2)
	var accent_light = create_light(Vector3(0, 0, 0))
	# хочу шоколадный цвет :)
	accent_light.light_color = Color.CHOCOLATE
	light.add_child(accent_light)
	add_child(light)


func _ready():
	# очистка сцены от текущих объектов
	for n in get_children():
		remove_child(n)
		n.queue_free()
	# добавляем пол
	add_floor(Vector3(3, 3, 3))
	# добавляем стену из кубов
	add_box_wall(42, 10, Vector3(-2, 0, 0), Vector3(0.1, 0.1, 0.1), Color.BURLYWOOD)
	# добавляем камеру
	add_camera()
	# добавляем свет
	add_light()


func bang():
	# позиция куба будет в этих границах
	var xr = randf_range(-2, 2)
	# а размер куба будет в этих
	var size = randf_range(0.1, 0.4)
	# создаём наш куб
	var box = create_box(Vector3(xr, 0.8, -3), Vector3(size, size, size), Color.CRIMSON)
	# выставляем случайный угол поворота
	box.rotation_degrees = Vector3(randi_range(0, 360), randi_range(0, 360), randi_range(0, 360))
	# выставляем массу
	box.mass = 10
	# добавляем импульс к созданному кубу
	box.apply_impulse(Vector3(0, 0, 15))
	# добавляем на сцену
	add_child(box)


# обработка пользовательского ввода
func _input(event):
	if event is InputEventKey:
		# закрытие окна
		if event.is_action_pressed("close"):
			get_tree().quit()
		
		# выстрел кубом
		if event.is_action_pressed("shoot"):
			bang()

		# пересоздание сцены
		if event.is_action_released("reset"):
			_ready()

		# управление камерой
		if event.is_action("ui_left"):
			camera.rotate_xz(dt)
		if event.is_action("ui_right"):
			camera.rotate_xz(-dt)
		if event.is_action("ui_up"):
			camera.increment_radius(-dt)
		if event.is_action("ui_down"):
			camera.increment_radius(dt)


# обработка логики зависящей от времени
func _process(delta):
	# передвигаем наш источник света
	light.rotate_xz(delta)
