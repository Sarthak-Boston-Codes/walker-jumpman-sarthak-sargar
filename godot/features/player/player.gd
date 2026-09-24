extends CharacterBody2D

const Tuning = preload("res://features/player/tuning.gd")
var tuning = Tuning.new()
var enabled: bool = false
var tick: int = 0
var last_floor_tick: int = -1000
var jump_request_tick: int = -1000
var opportunity_consumed: bool = false
var require_jump_release: bool = true
var facing: float = 1.0
var jumps: int = 0
var airborne: bool = false
var test_control: bool = false
var test_axis: float = 0.0
var test_jump_pressed: bool = false
var test_jump_held: bool = false

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 28)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(0, -14)
	add_child(collider)

func reset_at(spawn: Vector2) -> void:
	position = spawn
	velocity = Vector2.ZERO
	last_floor_tick = -1000
	jump_request_tick = -1000
	opportunity_consumed = false
	require_jump_release = true
	test_jump_pressed = false
	jumps = 0
	airborne = false
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	tick += 1
	var axis := test_axis if test_control else Input.get_axis("move_left", "move_right")
	var held := test_jump_held if test_control else Input.is_action_pressed("jump")
	var pressed := test_jump_pressed if test_control else Input.is_action_just_pressed("jump")
	test_jump_pressed = false
	if not held:
		require_jump_release = false
	if is_on_floor() and velocity.y >= 0.0:
		last_floor_tick = tick
		opportunity_consumed = false
	if pressed and not require_jump_release:
		jump_request_tick = tick
	var rate: float = tuning.acceleration if not is_zero_approx(axis) else tuning.deceleration
	velocity.x = move_toward(velocity.x, axis * tuning.speed, rate * delta)
	if not is_zero_approx(axis):
		facing = signf(axis)
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)
	if not opportunity_consumed and tick - last_floor_tick <= tuning.coyote_ticks and tick - jump_request_tick <= tuning.buffer_ticks:
		velocity.y = tuning.jump_velocity
		opportunity_consumed = true
		jump_request_tick = -1000
		jumps += 1
	move_and_slide()
	position.x = maxf(position.x, 10.0)
	airborne = not is_on_floor()
	queue_redraw()

## Visual-only pose state: wings sweep out while jumping or falling.
func wings_open() -> bool:
	return airborne

# Points are authored facing right; mirror x for the current facing.
func _facing(points: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(Vector2(p.x * facing, p.y))
	return out

func _draw() -> void:
	# Cardinal: rounded scout-bird drawn inside the unchanged 18x28 collider.
	var ink := Color("25354a")
	var red := Color("e0532f")
	var wing := Color("a8321f")
	var stride := sin(float(tick) * 0.7) * 2.0 if is_on_floor() and absf(velocity.x) > 8 else 0.0
	draw_rect(Rect2(-6, -4, 5, 4 + stride), ink)
	draw_rect(Rect2(2, -4, 5, 4 - stride), ink)
	if wings_open():
		draw_colored_polygon(_facing([Vector2(1, -18), Vector2(11, -29), Vector2(6, -14)]), wing.darkened(0.25))
	for crest in [[-5, -8], [-2, -9], [1, -8]]:
		draw_colored_polygon(_facing([Vector2(crest[0], -24), Vector2(crest[0] - 1, -24 + crest[1]), Vector2(crest[0] + 3, -25)]), red)
	var body := _facing([Vector2(2, -26), Vector2(6, -24), Vector2(8, -20), Vector2(8, -14), Vector2(7, -9), Vector2(4, -5), Vector2(-1, -4), Vector2(-6, -5), Vector2(-10, -8), Vector2(-8, -13), Vector2(-8, -19), Vector2(-6, -24), Vector2(-2, -26)])
	draw_colored_polygon(body, red)
	var outline := body.duplicate()
	outline.append(body[0])
	draw_polyline(outline, ink, 1.5)
	draw_colored_polygon(_facing([Vector2(7, -21), Vector2(12, -19), Vector2(7, -17)]), Color("f2b53a"))
	draw_rect(Rect2(Vector2(2 * facing - 1, -23), Vector2(3, 3)), Color("fff9e9"))
	draw_rect(Rect2(Vector2(3 * facing - 0.5, -22), Vector2(1.5, 2)), ink)
	if wings_open():
		draw_colored_polygon(_facing([Vector2(-1, -17), Vector2(-16, -26), Vector2(-12, -13), Vector2(-3, -11)]), wing)
	else:
		draw_colored_polygon(_facing([Vector2(-4, -18), Vector2(4, -15), Vector2(-6, -9)]), wing)
