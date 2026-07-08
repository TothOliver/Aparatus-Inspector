extends Node

@onready var health_bar = %HealthBar
@onready var sanity_bar = %SanityBar

# Scoring
var missed_robots_score: int = 0
var processed_today: int = 0
# Day Progression
var current_day: int = 1
var max_days: int = 3

# BAD AI let in
var bad_ai_let_in_count: int = 0
var bad_ai_killed: int = 0
var sanity: int = 100:
	set(value):
		sanity = value
		GameStats.player_sanity = value
		if sanity_bar:
			sanity_bar.value = value

var health: int = 100:
	set(value):
		health = value
		GameStats.player_health = value
		if health_bar:
			health_bar.value = value
const MAX_ALLOWED_BAD_AI = 2

# Day Configurations: [Quota, Difficulty Level]
var day_configs = {
	1: {"quota": 3, "difficulty": 1},
	2: {"quota": 4, "difficulty": 2},
	3: {"quota": 5, "difficulty": 3}
}

var hack_timer: float = 0.0
var sanity_drain_accumulator: float = 0.0

func _ready():
	current_day = GameStats.current_day
	start_new_day()

func _process(delta):
	# Keep day stats synced
	GameStats.current_day = current_day
	
	# Hacking events: Day 2 or 3 only, and only if WiFi is enabled!
	if current_day >= 2:
		if not GameStats.wifi_on:
			if GameStats.hack_active:
				GameStats.hack_active = false
				GameStats.hack_progress = 0.0
				print("Intrusion connection aborted (WiFi turned off).")
		else:
			if not GameStats.hack_active:
				hack_timer -= delta
				if hack_timer <= 0:
					# Trigger system breach!
					GameStats.hack_active = true
					GameStats.hack_progress = 0.0
					# Day 2 hacks: ~52.5-82.5s, Day 3 hacks: ~27-52.5s (50% longer than original)
					var min_time = 52.5 if current_day == 2 else 27.0
					var max_time = 82.5 if current_day == 2 else 52.5
					hack_timer = randf_range(min_time, max_time)

	# Slow sanity drain when lights are not on
	var game_3d = get_tree().current_scene
	if game_3d and "is_ceiling_light_on" in game_3d:
		var lights_are_off = not game_3d.is_ceiling_light_on or game_3d.is_blackout
		if lights_are_off:
			sanity_drain_accumulator += delta * 0.4 # ~1 sanity per 2.5 seconds
			if sanity_drain_accumulator >= 1.0:
				var amount = int(sanity_drain_accumulator)
				sanity = max(0, sanity - amount)
				sanity_drain_accumulator -= amount
				if sanity == 0:
					game_over_death()

func start_new_day():
	processed_today = 0
	GameStats.current_day = current_day
	
	# Clear previous day's hallway threats
	GameStats.let_through_bad_sprites.clear()
	GameStats.door_locked = false
	
	# Close door mesh if it was left open
	var door = get_tree().root.find_child("LeftDoor", true, false)
	if door:
		door.rotation.y = 0.0
		
	# Load persisted health/sanity
	sanity = int(GameStats.player_sanity)
	health = int(GameStats.player_health)
		
	var config = day_configs[current_day]
	print("--- DAY ", current_day, " START ---")
	print("Quota: ", config.quota, " | Difficulty Level: ", config.difficulty)
	
	# Start hack timer shortly after day start on Day 2/3 (50% longer initial delay)
	if current_day >= 2:
		hack_timer = randf_range(22.5, 45.0)

func process_robot(robot: RobotData, player_choice_pass: bool):
	var is_good_robot = robot.is_good
	if player_choice_pass:
		if not is_good_robot:
			# ADMITTED A BAD AI
			bad_ai_let_in_count += 1
			GameStats.total_security_breaches = bad_ai_let_in_count
			if robot.sprite:
				GameStats.let_through_bad_sprites.append(robot.sprite)
			print("SECURITY BREACH! Bad AI admitted and is now roaming. Total: ", bad_ai_let_in_count)
			print("Fail! You let a bad robot in.")
			GameStats.casino_balance = max(0.0, GameStats.casino_balance - 15.0)
			health = max(0, health - 25)
			if health == 0:
				game_over_death()
				return
		else:
			print("Success! Good robot admitted.")
			GameStats.good_robots_through += 1
			GameStats.casino_balance += 20.0
	else:
		if is_good_robot:
			GameStats.innocent_robots_killed += 1
			sanity = max(0, sanity - 25)
			if sanity == 0:
				game_over_death()
				return
			if sanity_bar:
				sanity_bar.value = sanity
			print("Fail! You rejected a perfectly good robot.")
			GameStats.casino_balance = max(0.0, GameStats.casino_balance - 15.0)
		else:
			print("Success! You caught a bad robot.")
			bad_ai_killed += 1
			GameStats.bad_robots_terminated = bad_ai_killed
			GameStats.casino_balance += 20.0
	
	var is_correct = (player_choice_pass == is_good_robot)
	if is_correct:
		processed_today += 1
		check_quota_progress()

func game_over_death():
	# Save the count of bad robots allowed through
	GameStats.total_security_breaches = bad_ai_let_in_count 
	GameStats.bad_robots_terminated = bad_ai_killed
	GameStats.is_victory = false
	print("YOU DIE")
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")

func check_quota_progress():
	if processed_today >= day_configs[current_day].quota:
		print("Quota Met for Day ", current_day, "! Transitioning to the next shift.")

func end_day():
	print("Day ", current_day, " finished!")
	if current_day < max_days:
		GameStats.current_day = current_day
		GameStats.change_scene_with_loading(get_tree(), "res://Scenes/StoryScreen.tscn")
	else:
		print("Game Over. Victory achieved!")
		GameStats.total_security_breaches = bad_ai_let_in_count
		GameStats.bad_robots_terminated = bad_ai_killed
		GameStats.is_victory = true
		GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")
		
