extends Node
## emitted when any data about players changes
signal players_changed(players: Array[Dictionary])
## emitted when the game state changes
signal game_state_changed(new_state: String)
## emitted when a multiplayer flag is queried with a different value
signal flag_updated(updated: String, value: bool)

const BASE_URL := "https://chloe.gregg.au/tasjam26/"
const LOG_MULTIPLAYER := false

enum FlagUpdate {
	OFF = 0,
	ON = 1,
	TOGGLE = 2
}

var http: HTTPRequest
var timer: Timer
var current_room_data: Dictionary = {
	"players": [],
	"state": "",
	"flags": {}
}
var room_code: String
var in_room := false
var in_game := false
var busy := false
var room_player_id: int
var username: String
@onready var connection_id := randi()

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	timer = Timer.new()
	timer.wait_time = 3
	timer.timeout.connect(check_for_updates)
	add_child(timer)

func get_my_data() -> Dictionary:
	return {
		"id": connection_id,
		"name": username
	}

func request(path: String, data: Variant = null) -> Variant:
	var url := BASE_URL + path
	if LOG_MULTIPLAYER: print("Multiplayer Requesting Url: %s" % url)
	while busy:
		await get_tree().process_frame
	http.request(url, [], HTTPClient.METHOD_POST, JSON.stringify({
		"me": get_my_data(),
		"data": data
	}))
	busy = true
	var response: Array = await http.request_completed
	busy = false
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

func check_for_updates() -> void:
	var room_data := await query_room()
	if not room_data:
		return
	var players: Array = room_data["players"]
	var state: String = room_data["state"]
	var flags: Dictionary = room_data["flags"]
	if len(players) != len(current_room_data["players"]):
		players_changed.emit(players)
		current_room_data["players"] = players
	else:
		for i in len(players):
			if not (
				players[i]["id"] == current_room_data["players"][i]["id"] and
				players[i]["name"] == current_room_data["players"][i]["name"]
			):
				current_room_data["players"] = players
				players_changed.emit(players)
				break
	
	if state != current_room_data["state"]:
		game_state_changed.emit(state)
		current_room_data["state"] = state
	
	for flag in flags:
		if flags[flag] != current_room_data["flags"].get(flag, false):
			current_room_data["flags"][flag] = flags[flag]
			flag_updated.emit(flag, flags[flag])

func on_room_entered() -> void:
	in_room = true
	timer.start()
	
func on_room_exited() -> void:
	in_room = false
	timer.stop()

func host_room() -> void:
	var response = await request("create_room")
	room_code = response as String
	room_player_id = 0
	on_room_entered()
	if LOG_MULTIPLAYER: print("Hosting Room. Code: %s" % room_code)

func join_room(code: String) -> bool:
	code = code.to_upper()
	var response = await request("join_room", code)
	if not response:
		return false
	room_code = code
	room_player_id = response as int
	on_room_entered()
	if LOG_MULTIPLAYER: print("Joining Room. Code: %s" % room_code)
	return true

func start_game() -> void:
	var _response = await request("start_game", room_code)
	if LOG_MULTIPLAYER: print("Starting Game")

func query_room() -> Dictionary:
	if in_room:
		var response = await request("query_room", room_code)
		return response as Dictionary
	else:
		return {}

func set_username(to: String) -> void:
	username = to
	if in_room:
		var _response = await request("update_player", room_code)

func update_flags(flag_changes: Dictionary[String, FlagUpdate]) -> void:
	if in_room:
		var _response = await request("update_flags", [room_code, flag_changes])
	else:
		push_warning("Toggling flags while not connected to a room")
		for flag in flag_changes:
			match flag_changes[flag]:
				FlagUpdate.OFF:
					current_room_data["flags"][flag] = false
				FlagUpdate.ON:
					current_room_data["flags"][flag] = true
				#FlagUpdate.TOGGLE:
				_:
					current_room_data["flags"][flag] = not current_room_data["flags"].get(flag, false)
			flag_updated.emit(flag, current_room_data["flags"][flag])
