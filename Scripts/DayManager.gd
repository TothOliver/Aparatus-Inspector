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
var sanity: int = 100
const MAX_ALLOWED_BAD_AI = 2

# Day Configurations: [Quota, Difficulty Level]
var day_configs = {
	1: {"quota": 3, "difficulty": 1},
	2: {"quota": 4, "difficulty": 2},
	3: {"quota": 5, "difficulty": 3}
}

var hack_timer: float = 0.0

func _ready():
	start_new_day()

func _process(delta):
	# Keep day stats synced
	GameStats.current_day = current_day
	
	# Hacking events: Day 2 or 3 only
	if current_day >= 2 and not GameStats.hack_active:
		hack_timer -= delta
		if hack_timer <= 0:
			# Trigger system breach!
			GameStats.hack_active = true
			GameStats.hack_progress = 0.0
			# Day 2 hacks: ~35-55s, Day 3 hacks: ~18-35s
			var min_time = 35.0 if current_day == 2 else 18.0
			var max_time = 55.0 if current_day == 2 else 35.0
			hack_timer = randf_range(min_time, max_time)

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
		
	# Reset/restore sanity
	sanity = 100
	if sanity_bar:
		sanity_bar.value = sanity
		
	var config = day_configs[current_day]
	print("--- DAY ", current_day, " START ---")
	print("Quota: ", config.quota, " | Difficulty Level: ", config.difficulty)
	
	# Start hack timer shortly after day start on Day 2/3
	if current_day >= 2:
		hack_timer = randf_range(15.0, 30.0)

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
		else:
			print("Success! Good robot admitted.")
			GameStats.good_robots_through += 1
	else:
		if is_good_robot:
			GameStats.innocent_robots_killed += 1
			sanity -= 25
			if sanity == 0:
				game_over_death()
			if sanity_bar:
				sanity_bar.value = sanity
			print("Fail! You rejected a perfectly good robot.")
		else:
			print("Success! You caught a bad robot.")
			bad_ai_killed += 1
			GameStats.bad_robots_terminated = bad_ai_killed
	
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
		end_day()

func end_day():
	print("Day ", current_day, " finished!")
	if current_day < max_days:
		current_day += 1
		start_new_day()
	else:
		print("Game Over. Victory achieved!")
		GameStats.total_security_breaches = bad_ai_let_in_count
		GameStats.bad_robots_terminated = bad_ai_killed
		GameStats.is_victory = true
		GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")
		
