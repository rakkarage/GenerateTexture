extends Control

@onready var _texture : TextureRect = $Texture
@onready var _generate : Button = $Generate
@onready var _save : Button = $Save

@export var _size := 128
@export var _seedMax := 65535
@export var _path := "res://TestGenerate.png"
@export var _noise := OpenSimplexNoise.new()

var _output := Image.new()

func _ready() -> void:
	_output.create(_size, _size, false, Image.FORMAT_RGBA8)
	assert(_generate.connect("pressed", _generatePressed) == OK)
	assert(_save.connect("pressed", _savePressed) == OK)
	_generatePressed()

func _generatePressed() -> void:
	_noise.seed += randi() % _seedMax
	var image1 := _noise.get_seamless_image(_size)
	_noise.seed += randi() % _seedMax
	var image2 := _noise.get_seamless_image(_size)
	_noise.seed += randi() % _seedMax
	var image3 := _noise.get_seamless_image(_size)

	for y in range(_size):
		for x in range(_size):
			var r = image1.get_pixel(x, y).r
			var g = image2.get_pixel(x, y).r
			var b = image3.get_pixel(x, y).r
			_output.set_pixel(x, y, Color(r, g, b))

	var new = ImageTexture.new()
	new.create_from_image(_output)
	_texture.texture = new

func _savePressed() -> void:
	_output.save_png(_path)
