class_name PlayerSpawn
extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scripts/root/entities/player/fpc/character.tscn")

func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	_spawn_player(1)
	multiplayer.peer_connected.connect(_spawn_player)


func _spawn_player(peer_id: int) -> void:
	if not PLAYER_SCENE.can_instantiate():
		return
	
	var new_player: CharacterBody3D = PLAYER_SCENE.instantiate()
	owner.add_child.call_deferred(new_player, true)
	new_player.name = str(peer_id)
