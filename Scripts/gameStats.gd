extends Node

var final_missed_score: int = 0
var total_security_breaches: int = 0
var innocent_robots_killed: int = 0
var good_robots_through: int = 0
var bad_robots_terminated: int = 0
var let_through_bad_sprites: Array = []

# Gameplay depth additions
var current_day: int = 1
var power_level: float = 100.0
var door_locked: bool = false
var hack_active: bool = false
var hack_progress: float = 0.0
var is_victory: bool = false
