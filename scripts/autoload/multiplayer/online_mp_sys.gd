# Autoload, no class_name
extends Node

const MAX_PLAYERS: int = 8
const ERRSTR_INVALID_SERVER_ADDRESS: String = "Invalid server address!"

var mp_peer: MultiplayerPeer = ENetMultiplayerPeer.new()

@onready var mp_default: MultiplayerAPI = get_tree().get_multiplayer()


func host_server(port: int = 5999):
    var err = mp_peer.create_server(port, MAX_PLAYERS)
    if err != OK:
        push_error("Could not create server! | Status code: %s" % err)
        return

    mp_default.multiplayer_peer = mp_peer


func join_server_parsed(ip: String, port: int):
    if not _validate_ip_and_port(ip, port):
        push_error("Invalid IP or port! (\"Well-known\" ports are not allowed!) | IP: %s | Port: %s" % [ip, port])
        return

    var err: int = mp_peer.create_client(ip, port)
    if err != OK:
        push_error("Could not join server! | Engine status code: %s" % err)
        return
    
    mp_default.multiplayer_peer = mp_peer


func parse_server_address(address: String) -> Array:
    var ip_and_port: PackedStringArray = address.split(":")
    if len(ip_and_port) != 2:
        push_error("%s (Length of string after split at \":\" char is not 2) | Address: %s" % [ERRSTR_INVALID_SERVER_ADDRESS, address])
        return []
    
    var ip: String = ip_and_port[0]
    var port_str: String = ip_and_port[1]

    if not _validate_ip_and_port_str(ip, port_str):
        push_error("%s (Engine could not validate ip as ip or port as int)" % ERRSTR_INVALID_SERVER_ADDRESS)
        return []

    var port: int = port_str.to_int()

    return [ip, port]


func _validate_ip_and_port_str(ip: String, port_str: String):
    return port_str.is_valid_int() and _is_valid_port(port_str.to_int()) and ip.is_valid_ip_address()


func _validate_ip_and_port(ip: String, port: int):
    return port_str.is_valid_int() and _is_valid_port(port_str.to_int()) and ip.is_valid_ip_address()


func _is_valid_port(port: int):
    return port != null and port > 1023