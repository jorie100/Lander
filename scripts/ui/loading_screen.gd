extends CanvasLayer

@export var progress_bar: ProgressBar
var progress: float = 0.0

func _process(_delta):
	progress_bar_update(progress)
	if progress_bar.value == 100.0:
		self.visible = false
				

func progress_bar_update(value: float):
	if progress_bar:
		progress_bar.value = value
