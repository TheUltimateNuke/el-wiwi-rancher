# Autoload, no class_name
extends Node

#signal upnp_setup_completed(error: int)
signal on_connection_timeout

const MAX_PLAYERS: int = 8
const DEFAULT_PORT: int = 5999
const LOAD_TIMEOUT: int = 10

const ERRSTR_INVALID_SERVER_ADDRESS: String = "Invalid server address!"

@onready var mp_peer: MultiplayerPeer = ENetMultiplayerPeer.new()
@onready var connection_timer: Timer = Timer.new()

#func _upnp_setup(server_port: int = DEFAULT_PORT):
	#var upnp = UPNP.new()
	#var err = upnp.discover()	
	#
	#if err != OK:
		#push_error("UPNP port forwarding failed! | Status code: %s" % err)
		#upnp_setup_completed.emit(err)
		#return
	#
	#var gateway = upnp.get_gateway()
	#if not gateway or not gateway.is_valid_gateway():
		#push_error("UPNP port forwarding failed! (Invalid gateway!)")
		#upnp_setup_completed.emit(FAILED)
		#return
	#
	#var project_name = ProjectSettings.get_setting("application/config/name")
	#upnp.add_port_mapping(server_port, server_port, "%s Server" % project_name, "UDP")
	#upnp.add_port_mapping(server_port, server_port, "%s Server" % project_name, "TCP")
	#upnp_setup_completed.emit(OK)

func _ready() -> void:
	add_child(connection_timer)
	connection_timer.timeout.connect(_on_connect_timeout)


func _process(_delta: float) -> void:
	if mp_peer.get_connection_status() == mp_peer.CONNECTION_CONNECTING and connection_timer.is_stopped():
		connection_timer.start(LOAD_TIMEOUT)
	else:
		connection_timer.stop()


func _on_connect_timeout():
	if mp_peer.get_connection_status() == mp_peer.CONNECTION_CONNECTING:
		connection_timer.stop()
		multiplayer.multiplayer_peer = null
		on_connection_timeout.emit()


func host_server(port: int = DEFAULT_PORT) -> int:
	if not _is_valid_port(port):
		return ERR_INVALID_PARAMETER

	var err: int = mp_peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		push_error("Could not create server! | Status code: %s" % err)
		return err

	mp_peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = mp_peer
	return err


func join_server(address: String) -> int:
	var ip_and_port = parse_and_validate_server_address(address)
	
	if ip_and_port == []:
		return FAILED

	var ip: String = ip_and_port[0]
	var port: int = ip_and_port[1]

	return join_server_parsed(ip, port)


func join_server_parsed(ip: String, port: int) -> int:	
	if not _validate_ip_and_port(ip, port):
		push_error("Could not join server! | Invalid IP or port! (\"Well-known\" 0-1023 ports are not allowed!) | IP: %s | Port: %s" % [ip, port])
		return ERR_INVALID_PARAMETER

	var err: int = mp_peer.create_client(ip, port)
	mp_peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	if err != OK:
		push_error("Could not join server! | Engine status code: %s" % err)
		return err	
		
	multiplayer.multiplayer_peer = mp_peer
	return err


func parse_and_validate_server_address(address: String) -> Array:
	var ip_and_port: PackedStringArray = address.split(":")
	if ip_and_port.size() != 2:
		push_warning("%s (Length of string after split at \":\" char is not 2, using default port with input. . .) | Address: %s" % [ERRSTR_INVALID_SERVER_ADDRESS, address])
		return [address, DEFAULT_PORT]
	
	var ip: String = ip_and_port[0]
	var port_str: String = ip_and_port[1] if ip_and_port[1] != null else DEFAULT_PORT

	if not _validate_ip_and_port_str(ip, port_str):
		push_error("%s (Engine could not validate ip as ip or port as int/valid port) | Address: %s" % [ERRSTR_INVALID_SERVER_ADDRESS, address])
		return []

	var port: int = port_str.to_int()

	return [ip, port]


func _validate_ip_and_port_str(ip: String, port_str: String):
	return port_str.is_valid_int() and _is_valid_port(port_str.to_int()) and ip.is_valid_ip_address()


func _validate_ip_and_port(ip: String, port: int):
	return _is_valid_port(port) and ip.is_valid_ip_address()


func _is_valid_port(port: int):
	return port != null and port > 1023
