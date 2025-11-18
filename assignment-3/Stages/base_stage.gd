extends Node3D

var player_scene = preload("res://Characters/Player/player_character.tscn")

var player: CharacterBody3D
var current_checkpoint: Node3D

func _ready():
	setup_stage()
	spawn_player()

func setup_stage():
	var checkpoints = $Checkpoints.get_children()
	for checkpoint in checkpoints:
		if checkpoint is Area3D:
			checkpoint.connect("checkpoint", _on_checkpoint_reached)
		if checkpoint.id == 0:
			current_checkpoint = checkpoint
	
	var goal = $Goal
	if goal is Node3D:
		goal.connect("goal", _on_goal_reached)

func spawn_player():
	player = player_scene.instantiate()
	add_child(player)
	
	respawn_player()
	player.connect("respawn", respawn_player)

func respawn_player():
	player.set_spawn_position(current_checkpoint.position)
	player.respawn()

func _on_checkpoint_reached(checkpoint: Area3D):
	if checkpoint.id > current_checkpoint.id:
		current_checkpoint = checkpoint
		player.set_spawn_position(current_checkpoint.position)

func _on_goal_reached():
	print("Goal Reached!")
