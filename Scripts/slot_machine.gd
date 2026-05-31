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
var balance: float = 100.0
var bet: float = 10.0
var is_spinning: bool = false

# Retro text symbols
var symbols = ["[ CHERRY ]", "[DIAMOND]", "[  BAR  ]", "[ ROBOT ]", "[ SEVEN ]"]

func _ready():
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

func _process(_delta):
	# Keep sanity display updated if DayManager exists
	var dm = get_day_manager()
	if dm and sanity_status_label:
		sanity_status_label.text = "Sanity: %d%%" % dm.sanity

func get_day_manager() -> Node:
	var dm = get_node_or_null("/root/Game3D/SubViewportContainer/SubViewport/Control2/DayManager")
	if not dm:
		dm = get_node_or_null("/root/Control2/DayManager")
	if not dm:
		dm = get_tree().root.find_child("DayManager", true, false)
	return dm

func update_ui():
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
	bet = min(100.0, bet + 10.0)
	update_ui()

func _on_bet_minus_pressed():
	if is_spinning: return
	bet = max(10.0, bet - 10.0)
	update_ui()

func _on_loan_pressed():
	if balance <= 0.0:
		balance = 10.0
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
		
		# Update active reels
		if elapsed < 0.6:
			r1_val = symbols.pick_random()
			reel1_label.text = r1_val
		else:
			if not r1_stopped:
				r1_stopped = true
				r1_val = symbols.pick_random()
				reel1_label.text = r1_val
				# Simple audio beep via terminal beep if desired or print
				
		if elapsed < 1.2:
			r2_val = symbols.pick_random()
			reel2_label.text = r2_val
		else:
			if not r2_stopped:
				r2_stopped = true
				r2_val = symbols.pick_random()
				reel2_label.text = r2_val
				
		if elapsed < 1.8:
			r3_val = symbols.pick_random()
			reel3_label.text = r3_val
		else:
			if not r3_stopped:
				r3_stopped = true
				r3_val = symbols.pick_random()
				reel3_label.text = r3_val
	
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
			"[DIAMOND]":
				win_amount = bet * 10.0
				text_outcome = "DIAMONDS! +$%d" % win_amount
			"[  BAR  ]":
				win_amount = bet * 5.0
				text_outcome = "BAR MATCH! +$%d" % win_amount
			"[ CHERRY ]":
				win_amount = bet * 3.0
				text_outcome = "CHERRIES! +$%d" % win_amount
			"[ ROBOT ]":
				win_amount = 0.0
				text_outcome = "ROBOT GLITCH! -15 SANITY!"
				# Drain player sanity as horror punishment!
				var dm = get_day_manager()
				if dm:
					dm.sanity = max(0, dm.sanity - 15)
					if dm.sanity_bar:
						dm.sanity_bar.value = dm.sanity
					if dm.sanity == 0:
						dm.game_over_death()
	elif r1 == r2 or r2 == r3 or r1 == r3:
		# Two of a kind (except robots)
		var pair_symbol = r2 if (r1 == r2 or r2 == r3) else r1
		if pair_symbol != "[ ROBOT ]":
			win_amount = bet * 1.5
			text_outcome = "Pair Match! +$%d" % win_amount
		else:
			text_outcome = "Robot pair... No payout."
	else:
		text_outcome = "No matches."
		
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
		update_ui()
