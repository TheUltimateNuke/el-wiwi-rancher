extends VBoxContainer

@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var ip_line_edit: LineEdit = $ServerAddressLineEdit

func _ready() -> void:
    assert(ip_line_edit or join_button or host_button)

    host_button.pressed.connect(_on_host_pressed)
    join_button.pressed.connect(_on_join_pressed)
    ip_line_edit.text_submitted.connect(_on_ip_submit)

func _on_ip_submit(_new_text: String):
    join_button.pressed.emit()

func _on_host_pressed(): 
    OnlineMPSys.host_server()

func _on_join_pressed():
    OnlineMPSys.join_server(ip, port)