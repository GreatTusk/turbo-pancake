extends AudioStreamPlayer

func _ready() -> void:
	self.finished.connect(_on_finished)
	
func _on_finished() -> void:
	"""
	WARNING: AudioStreamPlayers seem to be broken on web exports. They do not
	get freed immediately upong calling queue_free() and this function in particular appears
	to get called whenever an AudioStreamPlayer finishes playing, NOT this individual instance.
	I still haven't confirmed that this is what is happening, but if I don't comment out the 
	following line, the music duplicates itself each time another AudioStreamPlayer finishes 
	playing.
	This is on WPA exports with threads and gdextension support.
	I haven't been able to get a single threaded export working. I get an emscript error about 
	something related to threads.
	
	UPDATE: When I set audio/general/default_playback_type.web to Stream, all the issues above 
	get fixed. Maybe I didn't read all the blogs and new documentation properly. Are samples 
	not meant to be used on multithreaded web exports? I still got some unrelated errors on the
	browser console when loading my levels:

	WebGL warning: drawArraysInstanced: Drawing to a destination rect smaller than the viewport rect. (This warning will only be given once) 
	
	On the godot debugger I get:
	E 0:00:00:0137   get_process_id: OS::get_process_id() is not available on the Web platform.
	<C++ Error>    Method/function failed. Returning: 0
	<C++ Source>   platform/web/os_web.cpp:128 @ get_process_id()
	
	No idea why.

	I'll try to get single threaded web exports to work next.
	4.3rc1
	"""
	self.play()
