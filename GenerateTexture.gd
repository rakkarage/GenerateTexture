extends Control

@onready var _texture : TextureRect = $Margin/HBox/Right/Middle/Panel2/Texture
@onready var _textureRed : TextureRect = $Margin/HBox/Right/Middle/Panel1/Red
@onready var _textureGreen : TextureRect = $Margin/HBox/Right/Top/Panel/Green
@onready var _textureBlue : TextureRect = $Margin/HBox/Right/Middle/Panel3/Blue
@onready var _preview : ColorRect = $Margin/HBox/Right/Bottom/Panel/Preview
@onready var _big : ColorRect = $Big

@onready var _colorEdit : LineEdit = $Margin/HBox/Left/Settings/Color/LineEdit
@onready var _colorPicker : ColorPickerButton = $Margin/HBox/Left/Settings/Color/ColorPicker
@onready var _seedEdit : LineEdit = $Margin/HBox/Left/Settings/Seed/LineEdit
@onready var _seedSlider : HSlider = $Margin/HBox/Left/Settings/Seed/HSlider
@onready var _octavesEdit : LineEdit = $Margin/HBox/Left/Settings/Octaves/LineEdit
@onready var _octavesSlider : HSlider = $Margin/HBox/Left/Settings/Octaves/HSlider
@onready var _periodEdit : LineEdit = $Margin/HBox/Left/Settings/Period/LineEdit
@onready var _periodSlider : HSlider = $Margin/HBox/Left/Settings/Period/HSlider
@onready var _persistenceEdit : LineEdit = $Margin/HBox/Left/Settings/Persistence/LineEdit
@onready var _persistenceSlider : HSlider = $Margin/HBox/Left/Settings/Persistence/HSlider
@onready var _lacunarityEdit : LineEdit = $Margin/HBox/Left/Settings/Lacunarity/LineEdit
@onready var _lacunaritySlider : HSlider = $Margin/HBox/Left/Settings/Lacunarity/HSlider

@onready var _generate : Button = $Margin/HBox/Left/Buttons/Generate
@onready var _reset : Button = $Margin/HBox/Left/Buttons/Reset
@onready var _save : Button = $Margin/HBox/Left/Buttons/Save

@export var _size := 128
@export var _seedMax := 65535
@export var _path := "res://GenerateTexture.png"
@export var _noise : OpenSimplexNoise

var _output := Image.new()

func _ready() -> void:
	_colorEdit.connect("text_changed", _colorEditChanged)
	_colorPicker.connect("color_changed", _colorPickerChanged)
	_seedEdit.connect("text_changed", _seedEditChanged)
	_seedSlider.connect("value_changed", _seedSliderChanged)
	_octavesEdit.connect("text_changed", _octavesEditChanged)
	_octavesSlider.connect("value_changed", _octavesSliderChanged)
	_periodEdit.connect("text_changed", _periodEditChanged)
	_periodSlider.connect("value_changed", _periodSliderChanged)
	_persistenceEdit.connect("text_changed", _persistenceEditChanged)
	_persistenceSlider.connect("value_changed", _persistenceSliderChanged)
	_lacunarityEdit.connect("text_changed", _lacunarityEditChanged)
	_lacunaritySlider.connect("value_changed", _lacunaritySliderChanged)
	_generate.connect("pressed", _generatePressed)
	_reset.connect("pressed", _resetPressed)
	_save.connect("pressed", _savePressed)
	_noise = OpenSimplexNoise.new()
	_preview.get_material().set_shader_param("color", Color.WHITE)
	_big.get_material().set_shader_param("color", Color.WHITE)
	_output.create(_size, _size, false, Image.FORMAT_RGBA8)
	call_deferred("_loadSettings")

func _generatePressed() -> void:
	var old := _noise.seed
	_noise.seed += randi() % _seedMax
	var image1 := _noise.get_seamless_image(_size)
	_noise.seed += randi() % _seedMax
	var image2 := _noise.get_seamless_image(_size)
	_noise.seed += randi() % _seedMax
	var image3 := _noise.get_seamless_image(_size)
	_noise.seed = old;
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
	_big.get_material().set_shader_param("noise", new)

func _resetPressed() -> void:
	_noise = OpenSimplexNoise.new()
	_preview.get_material().set_shader_param("color", Color.WHITE)
	_big.get_material().set_shader_param("color", Color.WHITE)
	_loadSettings()

func _savePressed() -> void:
	_output.save_png(_path)

func _loadSettings() -> void:
	var color : Color = _preview.get_material().get_shader_param("color")
	_colorEdit.text = _colorPicker.color.to_html()
	_colorPicker.color = color
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
	_generatePressed()

func _colorEditChanged(value: String) -> void:
	var v := Color(value)
	_preview.get_material().set_shader_param("color", v)
	_big.get_material().set_shader_param("color", v)
	_colorPicker.color = v

func _colorPickerChanged(value: Color) -> void:
	_preview.get_material().set_shader_param("color", value)
	_big.get_material().set_shader_param("color", value)
	_colorEdit.text = value.to_html()

func _seedEditChanged(value: String) -> void:
	var v := value.to_int()
	_noise.seed = v
	_seedSlider.value = v
	call_deferred("_generatePressed")

func _seedSliderChanged(value: float) -> void:
	var v := int(value)
	_noise.seed = v
	_seedEdit.text = str(v)
	call_deferred("_generatePressed")

func _octavesEditChanged(value: String) -> void:
	var v := value.to_int()
	_noise.octaves = v
	_octavesSlider.value = v
	call_deferred("_generatePressed")

func _octavesSliderChanged(value: float) -> void:
	var v := int(value)
	_noise.octaves = v
	_octavesEdit.text = str(v)
	call_deferred("_generatePressed")

func _periodEditChanged(value: String) -> void:
	var v := value.to_float()
	_noise.period = v
	_periodSlider.value = v
	call_deferred("_generatePressed")

func _periodSliderChanged(value: float) -> void:
	_noise.period = value
	_periodEdit.text = str(value)
	call_deferred("_generatePressed")

func _persistenceEditChanged(value: String) -> void:
	var v := value.to_float()
	_noise.persistence = v
	_persistenceSlider.value = v
	call_deferred("_generatePressed")

func _persistenceSliderChanged(value: float) -> void:
	_noise.persistence = value
	_persistenceEdit.text = str(value)
	call_deferred("_generatePressed")

func _lacunarityEditChanged(value: String) -> void:
	var v := value.to_float()
	_noise.lacunarity = v
	_lacunaritySlider.value = v
	call_deferred("_generatePressed")

func _lacunaritySliderChanged(value: float) -> void:
	_noise.lacunarity = value
	_lacunarityEdit.text = str(value)
	call_deferred("_generatePressed")
