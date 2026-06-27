extends Node

const BASE_URL := "https://chloe.gregg.au/tasjam26/"
const LOG_MULTIPLAYER := true

var http: HTTPRequest
var room_code: String
var in_room := false
var room_player_id: int
var username: String
@onready var connection_id := randi()

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)

func get_my_data() -> Dictionary:
	return {
		"id": connection_id,
		"name": username
	}

func request(path: String, data: Variant = null) -> Variant:
	var url := BASE_URL + path
	if LOG_MULTIPLAYER: print("Multiplayer Requesting Url: %s" % url)
	http.request(url, [], HTTPClient.METHOD_POST, JSON.stringify({
		"me": get_my_data(),
		"data": data
	}))
	var response: Array = await http.request_completed
	var response_result: HTTPRequest.Result = response[0]
	var response_code: int = response[1]
	var _response_headers: PackedStringArray = response[2]
	var response_body: PackedByteArray = response[3]
	if response[0] != HTTPRequest.Result.RESULT_SUCCESS or response_code != 200:
		if response_result == HTTPRequest.Result.RESULT_TIMEOUT:
			push_error("Multiplayer Request Timed out")
		else:
			push_error("Multiplayer Request Failed: result: %d, code: %d" % [response_result, response_code])
		return null
	if LOG_MULTIPLAYER: print("Multiplayer Response: code %d, bytes %d" % [response_code, len(response_body)])
	var text := response_body.get_string_from_utf8()
	return JSON.parse_string(text)

func host_room() -> void:
	var response = await request("create_room")
	room_code = response as String
	room_player_id = 0
	in_room = true
	if LOG_MULTIPLAYER: print("Hosting Room. Code: %s" % room_code)

func join_room(code: String) -> bool:
	var response = await request("join_room", code)
	if not response:
		return false
	room_code = code
	room_player_id = response as int
	in_room = true
	if LOG_MULTIPLAYER: print("Joining Room. Code: %s" % room_code)
	return true

func query_room() -> Dictionary:
	var response = await request("query_room", room_code)
	return response as Dictionary

func set_username(to: String) -> void:
	username = to
	if in_room:
		var _response = await request("update_player", room_code)
