extends SceneTree
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var results: Array[Dictionary] = []
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func steps(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func check(id: String, passed: bool, observation: Dictionary) -> void:
	results.append({"id": id, "status": "PASS" if passed else "FAIL", "observed": observation})
	if not passed:
		failures += 1
	print(JSON.stringify(results.back()))

func fresh() -> void:
	if is_instance_valid(game):
		game.queue_free()
		await process_frame
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()
	game.player.test_control = true
	await steps(3)

# Real-input jump trial: stand at start_x, run right, jump at jump_x, hold right
# for `hold` ticks after takeoff (-1 = until landing), then release and settle.
func technique(start_x: float, jump_x: float, hold: int) -> Dictionary:
	await fresh()
	var p = game.player
	p.position = Vector2(start_x, 320)
	await steps(3)
	p.test_axis = 1
	var air := -1
	for i in range(240):
		if air < 0 and p.position.x >= jump_x and p.is_on_floor():
			p.test_jump_pressed = true
			air = 0
		await steps(1)
		if air >= 0:
			air += 1
			if hold >= 0 and air > hold:
				p.test_axis = 0
			if air > 3 and p.is_on_floor():
				p.test_axis = 0
				await steps(12)
				break
		if game.state != Game.State.PLAYING:
			break
	return {"state":game.state, "x":p.position.x, "on_floor":p.is_on_floor()}

func run() -> void:
	await fresh()
	check("launch-grounded", game.player.is_on_floor() and game.state == Game.State.PLAYING, {"position": str(game.player.position), "engine": Engine.get_version_info().string})
	game.player.test_axis = 1
	await steps(8)
	check("speed-cap", is_equal_approx(game.player.velocity.x,160), {"velocity_x": game.player.velocity.x})
	game.player.test_axis = 0
	await steps(5)
	check("neutral-stop", is_zero_approx(game.player.velocity.x), {"velocity_x": game.player.velocity.x})
	game.player.test_control = false
	Input.action_press("move_left")
	Input.action_press("move_right")
	await steps(5)
	check("simultaneous-directions", is_zero_approx(game.player.velocity.x), {"velocity_x": game.player.velocity.x})
	Input.action_release("move_left")
	Input.action_release("move_right")
	game.player.test_control = true
	game.player.test_axis = -1
	await steps(70)
	check("left-wall", game.player.position.x >= 9 and game.player.position.x <= 11, {"x": game.player.position.x})
	await fresh()
	game.player.test_jump_pressed = true
	game.player.test_jump_held = true
	var min_y: float = game.player.position.y
	for i in range(50):
		await steps(1)
		min_y = minf(min_y, game.player.position.y)
		if i == 12:
			game.player.test_jump_pressed = true
	check("fixed-jump-and-no-double", game.player.jumps == 1 and absf((320-min_y)-53.3333) < 5, {"rise_px":320-min_y, "jumps":game.player.jumps})
	await steps(30)
	check("held-jump-no-bounce", game.player.jumps == 1 and game.player.is_on_floor(), {"jumps":game.player.jumps})
	await fresh()
	var grounded_closed: bool = not game.player.wings_open()
	game.player.test_jump_pressed = true
	await steps(10)
	var airborne_open: bool = game.player.wings_open()
	await steps(40)
	var landed_closed: bool = not game.player.wings_open() and game.player.is_on_floor()
	check("wing-pose-follows-floor", grounded_closed and airborne_open and landed_closed, {"grounded_closed":grounded_closed,"airborne_open":airborne_open,"landed_closed":landed_closed})
	# Actual geometry fixtures at a ledge; tick ages exercise inclusive 6 / expired 7.
	for age in [5,6,7]:
		await fresh()
		game.player.position = Vector2(478, 285)
		await steps(2)
		game.player.last_floor_tick = game.player.tick + 1 - age
		game.player.opportunity_consumed = false
		game.player.test_jump_pressed = true
		await steps(1)
		check("coyote-%d" % age, (game.player.jumps == 1) == (age <= 6), {"age":age, "jumps":game.player.jumps})
	for age in [5,6,7]:
		await fresh()
		game.player.jump_request_tick = game.player.tick + 1 - age
		await steps(1)
		check("buffer-%d" % age, (game.player.jumps == 1) == (age <= 6), {"age":age, "jumps":game.player.jumps})
	await fresh()
	game._add_solid(Rect2(32,260,64,12))
	await steps(2)
	game.player.test_jump_pressed = true
	min_y = 320
	for i in range(45):
		await steps(1)
		min_y = minf(min_y,game.player.position.y)
	check("low-ceiling", min_y >= 300-0.2 and game.player.jumps == 1 and game.player.is_on_floor(), {"minimum_feet_y":min_y,"jumps":game.player.jumps})
	await fresh()
	game.player.test_jump_pressed = true
	await steps(5)
	game.set_paused(true)
	var paused_position: Vector2 = game.player.position
	var paused_time: float = game.elapsed
	await steps(10)
	check("pause-freezes", game.player.position == paused_position and game.elapsed == paused_time, {"position":str(game.player.position),"elapsed":game.elapsed})
	game.set_paused(false)
	game.test_mode = false
	game._on_focus_lost()
	check("focus-loss-pauses", game.state == Game.State.PAUSED, {"state":game.state})
	game.test_mode = true
	await fresh()
	game.player.position = Vector2(330,310)
	await steps(4)
	check("actual-spike-collision", game.state == Game.State.DYING and game.deaths == 1, {"state":game.state,"deaths":game.deaths})
	game.resolve_contacts(true,true)
	check("duplicate-death-ignored", game.deaths == 1, {"deaths":game.deaths})
	await steps(38)
	check("respawn", game.state == Game.State.PLAYING and game.player.position.distance_to(Vector2(64,320)) < 1, {"state":game.state,"position":str(game.player.position)})
	game.restart_attempt()
	check("manual-restart-not-death", game.deaths == 1, {"deaths":game.deaths})
	var largest_retry_ticks: int = 0
	for i in range(20):
		game.resolve_contacts(true,false)
		var waited := 0
		while game.state == Game.State.DYING and waited < 65:
			await steps(1)
			waited += 1
		largest_retry_ticks = maxi(largest_retry_ticks, waited)
	check("twenty-retries", game.deaths == 21 and largest_retry_ticks <= 60, {"deaths":game.deaths,"max_retry_ticks":largest_retry_ticks})
	await fresh()
	game.resolve_contacts(true,true)
	check("death-before-finish", game.state == Game.State.DYING, {"state":game.state})
	await fresh()
	game.player.position = Vector2(415,432)
	await steps(1)
	check("fall-boundary", game.state == Game.State.DYING, {"state":game.state})
	# Two-Step Crossing: original geometry intact, then both techniques each way.
	var original_solids := [[0, 320, 448, 64], [512, 320, 224, 64], [784, 320, 176, 64], [160, 304, 48, 16], [576, 288, 48, 32]]
	var level_solids: Array = game.level.solids.slice(0, 5).map(func(s): return s.map(func(v): return int(v)))
	var first_hazard: Array = game.level.hazards[0].map(func(v): return int(v))
	check("original-geometry-intact", level_solids == original_solids and first_hazard == [320, 304, 24, 16], {"solids":level_solids,"hazard":first_hazard})
	var t: Dictionary = await technique(850, 955, -1)
	check("full-hold-off-ledge-edge-overshoots", t.state == Game.State.DYING, t)
	t = await technique(850, 955, 22)
	check("short-hop-lands-landing-1", t.state == Game.State.PLAYING and t.on_floor and t.x >= 1007 and t.x <= 1057, t)
	t = await technique(1016, 1048, 16)
	check("short-hop-from-landing-1-fails", t.state == Game.State.DYING, t)
	t = await technique(1016, 1048, -1)
	check("full-jump-from-landing-1-clears-spike", t.state == Game.State.PLAYING and t.on_floor and t.x > 1137, t)
	await fresh()
	game.player.position = Vector2(920, 320)
	await steps(10)
	check("old-finish-is-pass-through", game.state == Game.State.PLAYING, {"state":game.state})
	game.player.position = Vector2(1030, 320)
	await steps(3)
	var view := Rect2(game.camera.position - Vector2(320, 180), Vector2(640, 360))
	var f: Array = game.level.finish
	var spike: Array = game.level.hazards[1]
	var ahead_visible: bool = view.encloses(Rect2(f[0], f[1], f[2], f[3])) and view.encloses(Rect2(spike[0], spike[1], spike[2], spike[3]))
	check("camera-shows-landing-2-from-landing-1", is_equal_approx(game.camera.position.x, float(game.level.width) - 320) and ahead_visible, {"camera_x":game.camera.position.x,"view":str(view)})
	var percent := {}
	for x in [916.0, 1030.0, 1236.0]:
		game.player.position.x = x
		percent[str(int(x))] = game.hud.progress()
	check("hud-below-100-at-old-finish", percent["916"] < 0.8 and percent["1030"] < 1.0, percent)
	check("hud-100-at-new-finish", is_equal_approx(percent["1236"], 1.0), percent)
	await fresh()
	var route = Route.new()
	var route_ticks := 0
	while game.state == Game.State.PLAYING and route_ticks < 900:
		route.step(game.player)
		await steps(1)
		route_ticks += 1
	check("complete-real-route", game.state == Game.State.COMPLETE and game.deaths == 0, {"state":game.state,"deaths":game.deaths,"ticks":route_ticks,"position":str(game.player.position),"jump_marks_used":route.next_jump})
	game.start_session()
	game.start_session()
	check("replay-idempotent", game.state == Game.State.PLAYING and game.deaths == 0 and game.player.jumps == 0, {"state":game.state,"deaths":game.deaths,"jumps":game.player.jumps})
	var report := {"scope":"First Steps slice; not full GDD acceptance or human playtesting", "engine":Engine.get_version_info().string,"created_at":Time.get_datetime_string_from_system(true),"results":results,"failures":failures}
	var out := ProjectSettings.globalize_path("res://../evidence")
	DirAccess.make_dir_recursive_absolute(out)
	var file := FileAccess.open(out + "/mechanics-" + str(Time.get_unix_time_from_system()) + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	file.close()
	print("WALKER TESTS: %d checks / %d failures" % [results.size(), failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
