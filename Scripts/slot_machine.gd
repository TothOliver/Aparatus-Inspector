extends Control

# Reel labels
@onready var reel1_label = %Reel1
@onready var reel2_label = %Reel2
@onready var reel3_label = %Reel3

# UI labels
@onready var balance_label = %BalanceLabel
@onready var bet_label = %BetLabel
@onready var win_label = %WinLabel
@onready var sanity_status_label = %SanityStatusLabel

# Buttons
@onready var spin_button = %SpinButton
@onready var bet_plus_btn = %BetPlusBtn
@onready var bet_minus_btn = %BetMinusBtn
@onready var loan_button = %LoanButton
@onready var buy_sanity_btn = %BuySanityBtn
@onready var buy_battery_btn = %BuyBatteryBtn

# Variables
var bet_values = [1.0, 5.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
var bet_index = 2
var last_displayed_balance: float = -1.0

var balance: float:
	get:
		return GameStats.casino_balance
	set(value):
		GameStats.casino_balance = round(value)

var bet: float:
	get:
		return bet_values[bet_index]

var is_spinning: bool = false

# Retro text symbols
var symbols = ["[ CHERRY ]", "[DIAMOND]", "[  BAR  ]", "[ ROBOT ]", "[ SEVEN ]"]

# Procedural audio players & streams
var tick_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var tick_stream: AudioStreamWAV
var stop_stream: AudioStreamWAV
var win_stream: AudioStreamWAV
var jackpot_stream: AudioStreamWAV
var lose_stream: AudioStreamWAV
var glitch_stream: AudioStreamWAV

func _ready():
	# Configure audio
	tick_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	tick_player.volume_db = -9.0
	sfx_player.volume_db = -9.0
	add_child(tick_player)
	add_child(sfx_player)
	
	tick_stream = _generate_tick_sound()
	stop_stream = _generate_stop_sound()
	win_stream = _generate_win_sound()
	jackpot_stream = _generate_jackpot_sound()
	lose_stream = _generate_lose_sound()
	glitch_stream = _generate_glitch_sound()

	# Initial UI state
	update_ui()
	if loan_button:
		loan_button.visible = false
	
	# Connect button signals
	spin_button.pressed.connect(_on_spin_pressed)
	if bet_plus_btn:
		bet_plus_btn.pressed.connect(_on_bet_plus_pressed)
	if bet_minus_btn:
		bet_minus_btn.pressed.connect(_on_bet_minus_pressed)
	if loan_button:
		loan_button.pressed.connect(_on_loan_pressed)
	if buy_sanity_btn:
		buy_sanity_btn.pressed.connect(_on_buy_sanity_pressed)
	if buy_battery_btn:
		buy_battery_btn.pressed.connect(_on_buy_battery_pressed)

func _play_tick():
	if tick_player and tick_stream:
		tick_player.stream = tick_stream
		tick_player.play()

func _play_sfx(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()

# === PROCEDURAL AUDIO GENERATION ===
func _generate_tick_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 400 # ~0.036s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-200.0 * t)
		var val = (randf() - 0.5) * env
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_stop_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 1500 # ~0.13s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-45.0 * t)
		var val = 0.5 if (fmod(t * 523.25, 1.0) < 0.5) else -0.5
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_win_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 8000 # ~0.72s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 523.25
		if t > 0.4:
			freq = 783.99
		elif t > 0.2:
			freq = 659.25
		var env = exp(-6.0 * (t - 0.4 if t > 0.4 else (t - 0.2 if t > 0.2 else t)))
		var val = 0.4 if (fmod(t * freq, 1.0) < 0.5) else -0.4
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_jackpot_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 15000 # ~1.36s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var note_idx = int(t * 12.0)
		var freq = 440.0 + (note_idx % 6) * 150.0 + (100.0 if note_idx > 6 else 0.0)
		var val = 0.5 if (fmod(t * freq, 1.0) < 0.5) else -0.5
		if randf() < 0.08:
			val += (randf() - 0.5) * 0.3
		var env = exp(-2.0 * t)
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_lose_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 5000 # ~0.45s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 220.0 - t * 240.0
		freq = max(50.0, freq)
		var env = exp(-8.0 * t)
		var val = 0.5 if (fmod(t * freq, 1.0) < 0.5) else -0.5
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_glitch_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 12000 # ~1.1s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 90.0 + sin(2.0 * PI * 15.0 * t) * 40.0
		var val = fmod(t * freq, 2.0) - 1.0
		val += (randf() - 0.5) * 0.6
		var env = exp(-3.0 * t)
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _process(_delta):
	# Keep sanity display updated if DayManager exists
	var dm = get_day_manager()
	if dm and sanity_status_label:
		sanity_status_label.text = "Sanity: %d%%" % dm.sanity
		
	# Keep balance label updated in real time if modified by other games
	if GameStats.casino_balance != last_displayed_balance:
		last_displayed_balance = GameStats.casino_balance
		update_ui()

func get_day_manager() -> Node:
	var dm = get_node_or_null("/root/Game3D/SubViewportContainer/SubViewport/Control2/DayManager")
	if not dm:
		dm = get_node_or_null("/root/Control2/DayManager")
	if not dm:
		dm = get_tree().root.find_child("DayManager", true, false)
	return dm

func update_ui():
	last_displayed_balance = GameStats.casino_balance
	if balance_label:
		balance_label.text = "$%d" % balance
	if bet_label:
		bet_label.text = "Bet: $%d" % bet
	
	# Enable/disable buy buttons based on balance
	if buy_sanity_btn:
		buy_sanity_btn.disabled = (balance < 50.0)
	if buy_battery_btn:
		buy_battery_btn.disabled = (balance < 40.0)
		
	# Show loan button if broke
	if loan_button:
		loan_button.visible = (balance <= 0.0 and not is_spinning)
		
	# Disable spin if balance too low
	spin_button.disabled = (balance < bet or is_spinning)

func _on_bet_plus_pressed():
	if is_spinning: return
	if bet_index < bet_values.size() - 1:
		bet_index += 1
		_play_sfx(tick_stream)
		update_ui()

func _on_bet_minus_pressed():
	if is_spinning: return
	if bet_index > 0:
		bet_index -= 1
		_play_sfx(tick_stream)
		update_ui()

func _on_loan_pressed():
	if balance <= 0.0:
		balance = 10.0
		_play_sfx(win_stream)
		if win_label:
			win_label.text = "Loan granted!"
		update_ui()

func _on_spin_pressed():
	if is_spinning or balance < bet:
		return
		
	is_spinning = true
	balance -= bet
	update_ui()
	
	if win_label:
		win_label.text = "Spinning..."
	
	# Pre-determine the spin outcome
	var r1_final = ""
	var r2_final = ""
	var r3_final = ""
	
	if randf() < 0.05:
		r1_final = "[ ROBOT ]"
		r2_final = "[ ROBOT ]"
		r3_final = "[ ROBOT ]"
	else:
		# Standard random pick, ensuring it is NOT triple robot (to maintain exactly 5% chance)
		r1_final = symbols.pick_random()
		r2_final = symbols.pick_random()
		r3_final = symbols.pick_random()
		while r1_final == "[ ROBOT ]" and r2_final == "[ ROBOT ]" and r3_final == "[ ROBOT ]":
			r1_final = symbols.pick_random()
			r2_final = symbols.pick_random()
			r3_final = symbols.pick_random()
			
	# Animate spin using timers/coroutine
	var elapsed = 0.0
	var tick_interval = 0.06
	var total_spin_time = 1.8
	
	var r1_stopped = false
	var r2_stopped = false
	var r3_stopped = false
	
	var r1_val = symbols[0]
	var r2_val = symbols[0]
	var r3_val = symbols[0]
	
	while elapsed < total_spin_time:
		await get_tree().create_timer(tick_interval).timeout
		elapsed += tick_interval
		
		var played_stop = false
		
		# Reel 1
		if elapsed < 0.6:
			r1_val = symbols.pick_random()
			reel1_label.text = r1_val
		else:
			if not r1_stopped:
				r1_stopped = true
				r1_val = r1_final
				reel1_label.text = r1_val
				_play_sfx(stop_stream)
				played_stop = true
				
		# Reel 2
		if elapsed < 1.2:
			r2_val = symbols.pick_random()
			reel2_label.text = r2_val
		else:
			if not r2_stopped:
				r2_stopped = true
				r2_val = r2_final
				reel2_label.text = r2_val
				if not played_stop:
					_play_sfx(stop_stream)
					played_stop = true
					
		# Reel 3
		if elapsed < 1.8:
			r3_val = symbols.pick_random()
			reel3_label.text = r3_val
		else:
			if not r3_stopped:
				r3_stopped = true
				r3_val = r3_final
				reel3_label.text = r3_val
				if not played_stop:
					_play_sfx(stop_stream)
					played_stop = true
					
		if not played_stop:
			_play_tick()
	
	# Calculate results
	calculate_win(r1_val, r2_val, r3_val)
	is_spinning = false
	update_ui()

func calculate_win(r1: String, r2: String, r3: String):
	var win_amount = 0.0
	var text_outcome = ""
	
	if r1 == r2 and r2 == r3:
		# Three of a kind
		match r1:
			"[ SEVEN ]":
				win_amount = bet * 15.0
				text_outcome = "JACKPOT! +$%d" % win_amount
				_play_sfx(jackpot_stream)
			"[DIAMOND]":
				win_amount = bet * 10.0
				text_outcome = "DIAMONDS! +$%d" % win_amount
				_play_sfx(win_stream)
			"[  BAR  ]":
				win_amount = bet * 5.0
				text_outcome = "BAR MATCH! +$%d" % win_amount
				_play_sfx(win_stream)
			"[ CHERRY ]":
				win_amount = bet * 3.0
				text_outcome = "CHERRIES! +$%d" % win_amount
				_play_sfx(win_stream)
			"[ ROBOT ]":
				win_amount = 0.0
				text_outcome = "ROBOT GLITCH! RUN!"
				_play_sfx(glitch_stream)
				
				# Drain player sanity as horror punishment!
				var dm = get_day_manager()
				if dm:
					dm.sanity = max(0, dm.sanity - 15)
					if dm.sanity_bar:
						dm.sanity_bar.value = dm.sanity
					if dm.sanity == 0:
						dm.game_over_death()
						return
						
				# Instantly trigger Hunter Robot chase!
				var hunter = get_tree().root.find_child("HunterRobot", true, false)
				if hunter:
					if GameStats.let_through_bad_sprites.is_empty():
						var robot_tex = load("res://Sprites/robot2.png")
						GameStats.let_through_bad_sprites.append(robot_tex)
					hunter.start_chase()
	elif r1 == r2 or r2 == r3 or r1 == r3:
		# Two of a kind (except robots)
		var pair_symbol = r2 if (r1 == r2 or r2 == r3) else r1
		if pair_symbol != "[ ROBOT ]":
			win_amount = bet * 1.5
			text_outcome = "Pair Match! +$%d" % win_amount
			_play_sfx(win_stream)
		else:
			text_outcome = "Robot pair... No payout."
			_play_sfx(lose_stream)
	else:
		text_outcome = "No matches."
		_play_sfx(lose_stream)
		
	balance += win_amount
	if win_label:
		win_label.text = text_outcome


func _on_buy_sanity_pressed():
	if balance >= 50.0:
		var dm = get_day_manager()
		if dm:
			if dm.sanity >= 100:
				if win_label:
					win_label.text = "Sanity already full!"
				return
			balance -= 50.0
			dm.sanity = min(100, dm.sanity + 25)
			if dm.sanity_bar:
				dm.sanity_bar.value = dm.sanity
			if win_label:
				win_label.text = "Bought Sanity Pack (+25)"
			_play_sfx(win_stream)
			update_ui()

func _on_buy_battery_pressed():
	if balance >= 40.0:
		if GameStats.power_level >= 100.0:
			if win_label:
				win_label.text = "Power grid already full!"
			return
		balance -= 40.0
		GameStats.power_level = min(100.0, GameStats.power_level + 25.0)
		if win_label:
			win_label.text = "Bought Battery Booster (+25%)"
		_play_sfx(win_stream)
		update_ui()
