extends RefCounted
## Fixed input route through the real level. No position/velocity edits.
## Each mark is [x, hold]: hold = -1 keeps right held through the jump; hold = N
## releases right N ticks after takeoff until landing (the Two-Step short hop).
var jump_marks: Array = [[138.0, -1], [292.0, -1], [424.0, -1], [548.0, -1], [712.0, -1], [955.0, 22], [1048.0, -1]]
var next_jump: int = 0
var hold_left: int = -1

func step(player: CharacterBody2D) -> void:
	player.test_control = true
	player.test_jump_held = false
	if hold_left == 0 and player.is_on_floor():
		hold_left = -1
	player.test_axis = 0.0 if hold_left == 0 else 1.0
	if hold_left > 0:
		hold_left -= 1
	if hold_left == -1 and next_jump < jump_marks.size() and player.position.x >= jump_marks[next_jump][0] and player.is_on_floor():
		player.test_jump_pressed = true
		hold_left = jump_marks[next_jump][1]
		next_jump += 1
