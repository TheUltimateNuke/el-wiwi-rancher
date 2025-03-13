# Autoload, no class_name
extends Node

const MAX_PLAYERS: int = 8

var mp_peer: MultiplayerPeer = ENetMultiplayerPeer.new()

@onready var mp_default: MultiplayerAPI = get_tree().get_multiplayer()

func host_server(port: int = 5999):
    assert(not mp_default.multiplayer_peer, "Already in a server!")

    var err = mp_peer.create_server(port, MAX_PLAYERS)
    

    mp_default.multiplayer_peer = mp_peer

func join_server(address: String, port: int):
    assert(not mp_default.multiplayer_peer, "Already in a server!")

    var err =mp_peer.create_client(address, port)
    
    mp_default.multiplayer_peer = mp_peer