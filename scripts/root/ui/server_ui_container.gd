extends VBoxContainer

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
	multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(_peer_id: int = -1):
	status_label.text = "Connected! Joining world. . ."


func _on_ip_submit(_new_text: String):
	if not join_button.disabled:
		join_button.pressed.emit()


func _on_host_pressed():
	var err = OnlineMPSys.host_server()
	status_label.text = "Waiting for server to start. . ."
	
	if err != OK:
		return
		
	host_button.disabled = true
	join_button.disabled = true


func _on_join_pressed():
	var err = OnlineMPSys.join_server(ip_line_edit.text)
	status_label.text = "Connecting to server. . ."
	
	if err != OK:
		status_label.text = "Connection failed, status code: %s" % err
		return
		
	host_button.disabled = true
	join_button.disabled = true
