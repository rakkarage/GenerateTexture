extends Control

@onready var _texture : TextureRect = $VBox/Middle/Panel2/Texture
@onready var _textureRed : TextureRect = $VBox/Middle/Panel1/Red
@onready var _textureGreen : TextureRect = $VBox/Top/Panel/Green
@onready var _textureBlue : TextureRect = $VBox/Middle/Panel3/Blue
@onready var _preview : TextureRect = $VBox/Bottom/Panel/Preview

@onready var _seedEdit : LineEdit = $VBox/Settings/Seed/LineEdit
@onready var _seedSlider : HSlider = $VBox/Settings/Seed/HSlider

@onready var _octavesEdit : LineEdit = $VBox/Settings/Octaves/LineEdit
@onready var _octavesSlider : HSlider = $VBox/Settings/Octaves/HSlider

@onready var _periodEdit : LineEdit = $VBox/Settings/Period/LineEdit
@onready var _periodSlider : HSlider = $VBox/Settings/Period/HSlider

@onready var _persistanceEdit : LineEdit = $VBox/Settings/Persistance/LineEdit
@onready var _persistanceSlider : HSlider = $VBox/Settings/Persistance/HSlider

@onready var _lacunarityEdit : LineEdit = $VBox/Settings/Lacunarity/LineEdit
@onready var _lacunaritySlider : HSlider = $VBox/Settings/Lacunarity/HSlider

@onready var _generate : Button = $VBox/Buttons/Generate
@onready var _save : Button = $VBox/Buttons/Save

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
	_loadSettings()

func _loadSettings() -> void:
	_seedEdit.text = str(_noise.seed)
	_seedSlider.value = _noise.seed
	_octavesEdit.text = str(_noise.octaves)
	_octavesSlider.value = _noise.octaves
	_periodEdit.text = str(_noise.period)
	_periodSlider.value = _noise.period
	_persistanceEdit.text = str(_noise.persistence)
	_persistanceSlider.value = _noise.persistence
	_lacunarityEdit.text = str(_noise.lacunarity)
	_lacunaritySlider.value = _noise.lacunarity

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
	_textureRed.texture = new
	_textureGreen.texture = new
	_textureBlue.texture = new

func _savePressed() -> void:
	_output.save_png(_path)
