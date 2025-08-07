extends Node

@onready var main_menu: CanvasLayer = $main_menu
@onready var address_entry: LineEdit = $main_menu/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var pause_menu: CanvasLayer = $pause_menu
@onready var connection_address: Label = $"pause_menu/Pause Menu/MarginContainer/VBoxContainer/ConnectionAddress"


const Player = preload("res://scenes/player/player.tscn")
const PORT = 9999
var peer = ENetMultiplayerPeer.new()


func _ready() -> void:
	pause_menu.hide()

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		pause_menu.show()
		get_tree().paused = true

func _on_host_button_pressed() -> void:
	main_menu.hide()
	
	peer.create_server(PORT, 3)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	upnp_setup()


func _on_join_button_pressed() -> void:
	main_menu.hide()
	
	peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
		
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
		
	print("Success! Join Address: %s" % upnp.query_external_address())
	connection_address.text = upnp.query_external_address()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_return_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()
