class_name PlayerCamera
extends Camera3D

const TWEEN_DURATION := 0.4
const POS_KEY := &"pos"
const REQUESTER_KEY := &"requester"
const ID_KEY := &"id"

static var main: PlayerCamera

@export var is_main := false

var requested_locations: Array[Dictionary] = []

var is_tweening := false
var tween_progress := 0.0

var requests := 0

func _ready() -> void:
	if is_main:
		if main:
			push_error("Second Main PlayerCamera")
		main = self

func _process(delta: float) -> void:
	tween_progress = minf(tween_progress+delta, TWEEN_DURATION)
	if is_tweening:
		transform = lerp(transform, requested_locations[-1][POS_KEY], tween_progress/TWEEN_DURATION)
		if tween_progress == TWEEN_DURATION:
			is_tweening = false
	else:
		if requested_locations.size() > 0:
			transform = requested_locations[-1][POS_KEY]

func request_camera(requested_transform: Transform3D, requester: Node, tween: bool) -> int:
	requests += 1
	requested_locations.append({POS_KEY: requested_transform, REQUESTER_KEY: requester, ID_KEY: requests})
	if tween:
		tween_camera()
	return requests

func tween_camera() -> void:
	is_tweening = true
	tween_progress = 0

func release_camera_by_requester(requester: Node) -> void:
	release_camera(REQUESTER_KEY, requester)
	
func release_camera_by_transform(requested_tranform: Transform3D) -> void:
	release_camera(POS_KEY, requested_tranform)

func release_camera_by_id(request_id: int) -> void:
	release_camera(ID_KEY, request_id)

func release_camera(key: StringName, value: Variant) -> void:
	for loc in requested_locations.size():
		if requested_locations[requested_locations.size() - loc - 1][key] == value:
			requested_locations.remove_at(requested_locations.size() - loc - 1)

func edit_request_transform(id: int, requested_transform: Transform3D) -> void:
	for loc in requested_locations:
		if loc[ID_KEY] == id:
			loc[POS_KEY] = requested_transform
			return

func has_camera(requester: Node) -> bool:
	return requester == requested_locations[-1][REQUESTER_KEY]
