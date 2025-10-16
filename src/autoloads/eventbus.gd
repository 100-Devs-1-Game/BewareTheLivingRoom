extends Node

@warning_ignore("unused_signal")
signal escaped_house
signal unlock_called(id: int)
signal lock_called(id: int)
signal game_started
signal interactable_observed(obj: Node3D)
signal interactable_unobserved(obj: Node3D)
signal switch_changed(id: int, state: bool)
signal camera_move_to(from: Vector3, to: Vector3, obj: Node3D)
signal power_toggled(state: bool)
signal monster_appearing
signal monster_left
signal force_exit_observe
signal exited_observe
signal killing_player
signal player_killed
signal bed_used(state: bool)

signal announced_dialogue(text: String)
signal announce_tooltip(text: String)


signal show_title
