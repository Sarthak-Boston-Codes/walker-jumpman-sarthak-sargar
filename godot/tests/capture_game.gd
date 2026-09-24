extends SceneTree
const Game = preload("res://game/session.gd")
const Route = preload("res://tests/route_driver.gd")
var game: Node2D
var output: String

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output + "/" + label + ".png")
	assert(error == OK)
	print("Captured rendered game viewport: " + label)

func run() -> void:
	output = ProjectSettings.globalize_path("res://../evidence/screens")
	DirAccess.make_dir_recursive_absolute(output)
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	for i in range(3): await step()
	await capture("01-menu")
	game.start_session()
	game.player.test_control = true
	game.player.test_axis = 1
	# Walk from a safe landing into the spike trigger, not an invented failure card.
	game.player.position = Vector2(275, 320)
	for i in range(90):
		await step()
		if game.state == Game.State.DYING: break
	assert(game.state == Game.State.DYING)
	await capture("02-failure")
	game.state = Game.State.MENU
	game.start_session()
	var route = Route.new()
	var gap_captured := false
	var crossing_captured := false
	for i in range(900):
		route.step(game.player)
		await step()
		if not gap_captured and game.player.position.x > 463 and game.player.position.y < 300:
			await capture("03-jump")
			gap_captured = true
		# Standing on Landing 1: spike, Landing 2, and the relocated flag must be in view.
		if not crossing_captured and game.player.position.x > 1010 and game.player.is_on_floor():
			await capture("05-crossing")
			crossing_captured = true
		if game.state != Game.State.PLAYING: break
	assert(game.state == Game.State.COMPLETE, "Input route did not complete")
	assert(crossing_captured, "Route never stood on Landing 1")
	await capture("04-complete")
	print("VISUAL ROUTE: completed with %d deaths" % game.deaths)
	game.queue_free()
	await process_frame
	quit()
