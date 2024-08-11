@tool # Required to show the enum in the editor
class_name VolumeSlider
extends HSlider

enum AudioBus {}

@export var audio_bus: AudioBus
@onready var debounce_timer: Timer = $DebounceTimer

var temp_vol: float

func _ready() -> void:
	self.value_changed.connect(_on_volume_changed)
	self.mouse_exited.connect(_on_focus_lost)
	self.value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus))
	debounce_timer.timeout.connect(_on_debounce_timer_timeout)
	#AudioServer.bus_renamed.connect(_on_bus_renamed)
	#AudioServer.bus_layout_changed.connect(_on_bus_layout_changed)

# Refer to audio_stream_player.cpp in the engine
# Other resources https://forum.godotengine.org/t/validate-property-not-working-with-enums/56843
# https://forum.godotengine.org/t/what-is-the-data-type-of-the-audiobus-and-can-i-export-it-as-a-variable/66760
func _validate_property(property: Dictionary) -> void:
	if property.name == "audio_bus":
		var options: String = ""
		for bus_index in range(0, AudioServer.get_bus_count()):
			if bus_index > 0:
				options += ","
			options += AudioServer.get_bus_name(bus_index)
		property.hint_string = options

func _on_volume_changed(volume: float) -> void:
	temp_vol = volume
	if debounce_timer.is_stopped():
		debounce_timer.start()

func _on_debounce_timer_timeout() -> void:
	AudioServer.set_bus_volume_db(audio_bus, linear_to_db(temp_vol))
	var audio_config: AudioSettings = ResourceLoader.load("user://config/audio_settings.tres")
	match audio_bus:
		1:
			audio_config.bgm_volume = temp_vol
		2:
			audio_config.sfx_volume = temp_vol
	ResourceSaver.save(audio_config, "user://config/audio_settings.tres")

func _on_bus_layout_changed() -> void:
	_validate_property.call()
	notify_property_list_changed()
	
func _on_bus_renamed() -> void:
	_validate_property.call()
	notify_property_list_changed()
	
func _on_focus_lost() -> void:
	self.release_focus()
