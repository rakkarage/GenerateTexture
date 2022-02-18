extends Control

@onready var _texture : TextureRect = $HBox/Right/Middle/Panel2/Texture
@onready var _textureRed : TextureRect = $HBox/Right/Middle/Panel1/Red
@onready var _textureGreen : TextureRect = $HBox/Right/Top/Panel/Green
@onready var _textureBlue : TextureRect = $HBox/Right/Middle/Panel3/Blue
@onready var _preview : TextureRect = $HBox/Right/Bottom/Panel/Preview

@onready var _colorEdit : LineEdit = $HBox/Left/Settings/Color/LineEdit
@onready var _colorPicker : ColorPickerButton = $HBox/Left/Settings/Color/ColorPicker
@onready var _seedEdit : LineEdit = $HBox/Left/Settings/Seed/LineEdit
@onready var _seedSlider : HSlider = $HBox/Left/Settings/Seed/HSlider
@onready var _octavesEdit : LineEdit = $HBox/Left/Settings/Octaves/LineEdit
@onready var _octavesSlider : HSlider = $HBox/Left/Settings/Octaves/HSlider
@onready var _periodEdit : LineEdit = $HBox/Left/Settings/Period/LineEdit
@onready var _periodSlider : HSlider = $HBox/Left/Settings/Period/HSlider
@onready var _persistenceEdit : LineEdit = $HBox/Left/Settings/Persistence/LineEdit
@onready var _persistenceSlider : HSlider = $HBox/Left/Settings/Persistence/HSlider
@onready var _lacunarityEdit : LineEdit = $HBox/Left/Settings/Lacunarity/LineEdit
@onready var _lacunaritySlider : HSlider = $HBox/Left/Settings/Lacunarity/HSlider

@onready var _generate : Button = $HBox/Left/Buttons/Generate
@onready var _reset : Button = $HBox/Left/Buttons/Reset
@onready var _save : Button = $HBox/Left/Buttons/Save

@export var _size := 128
@export var _seedMax := 65535
@export var _path := "res://GenerateTexture.png"
@export var _noise := OpenSimplexNoise.new()

var _output := Image.new()

func _ready() -> void:
	_output.create(_size, _size, false, Image.FORMAT_RGBA8)
	assert(_colorEdit.connect("text_changed", _colorEditChanged) == OK)
	assert(_colorPicker.connect("color_changed", _colorPickerChanged) == OK)
	assert(_seedEdit.connect("text_changed", _seedEditChanged) == OK)
	assert(_seedSlider.connect("value_changed", _seedSliderChanged) == OK)
	assert(_octavesEdit.connect("text_changed", _octavesEditChanged) == OK)
	assert(_octavesSlider.connect("value_changed", _octavesSliderChanged) == OK)
	assert(_periodEdit.connect("text_changed", _periodEditChanged) == OK)
	assert(_periodSlider.connect("value_changed", _periodSliderChanged) == OK)
	assert(_persistenceEdit.connect("text_changed", _persistenceEditChanged) == OK)
	assert(_persistenceSlider.connect("value_changed", _persistenceSliderChanged) == OK)
	assert(_lacunarityEdit.connect("text_changed", _lacunarityEditChanged) == OK)
	assert(_lacunaritySlider.connect("value_changed", _lacunaritySliderChanged) == OK)
	assert(_generate.connect("pressed", _generatePressed) == OK)
	assert(_reset.connect("pressed", _resetPressed) == OK)
	assert(_save.connect("pressed", _savePressed) == OK)
	_generatePressed()
	_loadSettings()

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
	_preview.get_material().set_shader_param("noise", new)

func _resetPressed() -> void:
	_noise = OpenSimplexNoise.new()
	_preview.get_material().set_shader_param("color", Color.WHITE)
	_generatePressed()
	_loadSettings()

func _savePressed() -> void:
	_output.save_png(_path)

func _loadSettings() -> void:
	_colorPicker.color = _preview.get_material().get_shader_param("color")
	_seedEdit.text = str(_noise.seed)
	_seedSlider.value = _noise.seed
	_octavesEdit.text = str(_noise.octaves)
	_octavesSlider.value = _noise.octaves
	_periodEdit.text = str(_noise.period)
	_periodSlider.value = _noise.period
	_persistenceEdit.text = str(_noise.persistence)
	_persistenceSlider.value = _noise.persistence
	_lacunarityEdit.text = str(_noise.lacunarity)
	_lacunaritySlider.value = _noise.lacunarity

var _ignore = false

func _colorEditChanged(value: String) -> void:
	if !_ignore:
		var v := Color(value)
		_preview.get_material().set_shader_param("color", v)
		_ignore = true
		_colorPicker.color = v
		_ignore = false
		call_deferred("_generatePressed")

func _colorPickerChanged(value: Color) -> void:
	if !_ignore:
		var v := str(value)
		_preview.get_material().set_shader_param("color", Color(v))
		_ignore = true
		_colorEdit.text = v
		_ignore = false
		call_deferred("_generatePressed")

func _seedEditChanged(value: String) -> void:
	if !_ignore:
		var v := value.to_int()
		_noise.seed = v
		_ignore = true
		_seedSlider.value = v
		_ignore = false
		call_deferred("_generatePressed")

func _seedSliderChanged(value: float) -> void:
	if !_ignore:
		var v := int(value)
		_noise.seed = v
		_ignore = true
		_seedEdit.text = str(v)
		_ignore = false
		call_deferred("_generatePressed")

func _octavesEditChanged(value: String) -> void:
	if !_ignore:
		var v := value.to_int()
		_noise.octaves = v
		_ignore = true
		_octavesSlider.value = v
		_ignore = false
		call_deferred("_generatePressed")

func _octavesSliderChanged(value: float) -> void:
	if !_ignore:
		var v := int(value)
		_noise.octaves = v
		_ignore = true
		_octavesEdit.text = str(v)
		_ignore = false
		call_deferred("_generatePressed")

func _periodEditChanged(value: String) -> void:
	if !_ignore:
		var v := value.to_float()
		_noise.period = v
		_ignore = true
		_periodSlider.value = v
		_ignore = false
		call_deferred("_generatePressed")

func _periodSliderChanged(value: float) -> void:
	if !_ignore:
		_noise.period = value
		_ignore = true
		_periodEdit.text = str(value)
		_ignore = false
		call_deferred("_generatePressed")

func _persistenceEditChanged(value: String) -> void:
	if !_ignore:
		var v := value.to_float()
		_noise.persistence = v
		_ignore = true
		_persistenceSlider.value = v
		_ignore = false
		call_deferred("_generatePressed")

func _persistenceSliderChanged(value: float) -> void:
	if !_ignore:
		_noise.persistence = value
		_ignore = true
		_persistenceEdit.text = str(value)
		_ignore = false
		call_deferred("_generatePressed")

func _lacunarityEditChanged(value: String) -> void:
	if !_ignore:
		var v := value.to_float()
		_noise.lacunarity = v
		_ignore = true
		_lacunaritySlider.value = v
		_ignore = false
		call_deferred("_generatePressed")

func _lacunaritySliderChanged(value: float) -> void:
	if !_ignore:
		_noise.lacunarity = value
		_ignore = true
		_lacunarityEdit.text = str(value)
		_ignore = false
		call_deferred("_generatePressed")
