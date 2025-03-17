extends VBoxContainer

const WORLD_SCENE: PackedScene = preload("res://scenes/world.tscn")

@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var status_label: Label = get_node("../Hello")
@onready var ip_line_edit: LineEdit = $ServerAddressLineEdit


func _ready() -> void:
	assert(ip_line_edit or join_button or host_button)

	# UI signals
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	ip_line_edit.text_submitted.connect(_on_ip_submit)
	
	# Multiplayer signals
	multiplayer.connected_to_server.connect(_on_peer_connected)
	OnlineMPSys.on_connection_timeout.connect(_on_connection_timeout)

func _on_connection_timeout():
	status_label.text = "Failed to join server: Connection timeout! boowomp"
	push_error("Failed to join server: Connection timeout! boowomp")
	
	host_button.disabled = false
	join_button.disabled = false


func _on_peer_connected():
	status_label.text = "Connected! Joining world. . ."
	get_tree().change_scene_to_packed(WORLD_SCENE)


func _on_ip_submit(_new_text: String):
	if not join_button.disabled:
		join_button.pressed.emit()


func _on_host_pressed():
	var err = OnlineMPSys.host_server()
	status_label.text = "Waiting for server to start. . ."
	
	if err != OK:
		status_label.text = "Connection failed, status code: %s" % err
		return
	
	_on_peer_connected()

func _on_join_pressed():
	var err = OnlineMPSys.join_server(ip_line_edit.text)
	status_label.text = "Connecting to server. . ."
	
	if err != OK:
		status_label.text = "Connection failed, status code: %s" % err
		return
		
	host_button.disabled = true
	join_button.disabled = true
