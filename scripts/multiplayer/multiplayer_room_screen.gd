class_name MultiplayerRoomScreen
extends Node

@export var lobby_player_scene: PackedScene

@onready var start: VBoxContainer = $Start
@onready var lobby: VBoxContainer = $Lobby
@onready var players_list: VBoxContainer = $Lobby/PlayersList

@onready var room_code_display: Label = $Lobby/RoomCode
@onready var room_code_input: LineEdit = $Start/RoomCodeInput
@onready var username_input: LineEdit = $Options/UsernameInput
@onready var lobby_refresh_timer: Timer = $LobbyRefreshTimer

var lobby_players: Dictionary[String, LobbyPlayer] = {}

func _ready() -> void:
	change_username("")

func host() -> void:
	await MultiplayerConnection.host_room()
	show_lobby()

func join() -> void:
	if await MultiplayerConnection.join_room(room_code_input.text):
		show_lobby()

func show_lobby() -> void:
	room_code_display.text = MultiplayerConnection.room_code
	refresh_lobby()
	lobby_refresh_timer.start()
	lobby.show()
	start.hide()

func show_start() -> void:
	for lobby_player in lobby_players.values():
		lobby_player.queue_free()
	lobby_players.clear()
	lobby.hide()
	start.show()

func refresh_lobby() -> void:
	var lobby_data := await MultiplayerConnection.query_room()
	var all_player_data: Array = lobby_data["players"]
	var left := lobby_players.keys()
	for player_data: Dictionary in all_player_data:
		if player_data["id"] not in lobby_players:
			lobby_players[player_data["id"]] = lobby_player_scene.instantiate()
			players_list.add_child(lobby_players[player_data["id"]])
		var lobby_player := lobby_players[player_data["id"]]
		lobby_player.set_username(player_data["name"])
		left.erase(player_data["id"])
	for removed in left:
		lobby_players[removed].queue_free()
		lobby_players.erase(removed)

func change_username(to: String) -> void:
	to = to.strip_edges()
	if len(to) >= 3 and len(to) <= 32:
		MultiplayerConnection.set_username(to)
	else:
		username_input.text = "Player%03d" % (randi() % 1000)
		MultiplayerConnection.set_username(username_input.text)

func username_touched(started: bool) -> void:
	if not started:
		change_username(username_input.text)
