# наследуемся от базовой ноды для 3D
extends Node3D
# имя класса нашей новой ноды
class_name Rotator


# наши любимые глобальные переменные
var _shift_angle: float = PI / 2
var _angle: float = 0
var _radius: float = 0


# конструктор
func _init(angle: int, radius: float, height: float):
	_radius = radius
	_angle = deg_to_rad(angle)
	position.y = height


# начальная инициализация
func _ready():
	rotate_xz(0)


# функция поворота камеры
func rotate_xz(delta: float):
	# увеличиваем наш угол
	_angle = fmod(_angle + delta, 2 * PI)
	# позиция камеры в зависимости от угла
	position.x = _radius * cos(_angle)
	position.z = _radius * sin(_angle)
	# и угол на который она повёрнута
	rotation.y = _shift_angle - _angle


# функция изменение радиуса
func increment_radius(delta: float):
	_radius += delta
	rotate_xz(0)
