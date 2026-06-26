extends Camera3D
class_name PlayerCamera

var requested_locations = []

var is_tweening = false
var tween_progress = 0
const TWEEN_DURATION = 0.4

var requests = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tween_progress = min(tween_progress+delta, TWEEN_DURATION)
	if is_tweening:
		transform = lerp(transform, requested_locations[-1]["pos"], tween_progress/TWEEN_DURATION)
		if tween_progress == TWEEN_DURATION:
			is_tweening = false
	else:
		if requested_locations.size() > 0:
			transform = requested_locations[-1]["pos"]

func request_camera(requested_transform : Transform3D, requester : Node, tween : bool):
	requests+=1
	requested_locations.append({"pos":requested_transform, "requester":requester, "id":requests})
	if tween:
		tween_camera()
	return requests

func tween_camera():
	is_tweening = true
	tween_progress = 0

func release_camera_by_requester(requester: Node):
	release_camera("requester", requester)
	
func release_camera_by_transform(requested_tranform: Transform3D):
	release_camera("pos", requested_tranform)

func release_camera_by_id(request_id: int):
	release_camera("id", request_id)

func release_camera(key : String, value):
	for loc in requested_locations.size():
		if requested_locations[requested_locations.size()-loc-1][key] == value:
			requested_locations.remove_at(requested_locations.size()-loc-1)

func edit_request_transform(id: int, requested_transform : Transform3D):
	for loc in requested_locations:
		if loc["id"] == id :
			loc["pos"] = requested_transform
			return

func has_camera(requester: Node):
	return (requester == requested_locations[-1]["requester"])
