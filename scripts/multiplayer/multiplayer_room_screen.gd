class_name MultiplayerRoomScreen
extends Node

const REQUIRED_PLAYERS := 2

@export var lobby_player_scene: PackedScene
@export var game_scene: PackedScene

@onready var start_section: VBoxContainer = $Start
@onready var lobby_section: VBoxContainer = $Lobby
@onready var players_list: VBoxContainer = $Lobby/PlayersList

@onready var room_code_display: Label = $Lobby/RoomCode
@onready var room_code_input: LineEdit = $Start/RoomCodeInput
@onready var username_input: LineEdit = $Options/UsernameInput
@onready var start_button: Button = $Lobby/StartButton

var lobby_players: Dictionary[String, LobbyPlayer] = {}

func _ready() -> void:
	MultiplayerConnection.players_changed.connect(refresh_lobby)
	MultiplayerConnection.game_state_changed.connect(game_state_changed)
	change_username("")

func game_state_changed(to: String) -> void:
	if to == "game":
		get_tree().change_scene_to_packed(game_scene)

func host() -> void:
	await MultiplayerConnection.host_room()
	start_button.show()
	show_lobby()

func join() -> void:
	if await MultiplayerConnection.join_room(room_code_input.text):
		start_button.hide()
		show_lobby()

func show_lobby() -> void:
	room_code_display.text = MultiplayerConnection.room_code
	MultiplayerConnection.check_for_updates()
	lobby_section.show()
	start_section.hide()

func show_start() -> void:
	for lobby_player in lobby_players.values():
		lobby_player.queue_free()
	lobby_players.clear()
	lobby_section.hide()
	start_section.show()

func refresh_lobby(all_player_data: Array) -> void:
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
	start_button.disabled = len(all_player_data) < REQUIRED_PLAYERS

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

func start() -> void:
	MultiplayerConnection.start_game()
