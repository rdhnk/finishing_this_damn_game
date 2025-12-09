extends Node2D

@onready var stopwatch_time : float = 0.0
@onready var stopwatch_stopped : bool = false

func _ready() -> void:
	print("Stopwatch: ", stopwatch_stopped)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stopwatch_stopped:
		return
	stopwatch_time += delta
	
func time_to_string() -> String:
	var msec = fmod(stopwatch_time, 1) * 1000
	var sec = fmod(stopwatch_time, 60)
	var minute = stopwatch_time / 60
	var format_string = "%02d : %02d : %02d"
	var time_string = format_string % [minute, sec, msec]
	return time_string
	
