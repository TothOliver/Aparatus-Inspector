extends Control

@onready var title_label = %Title
@onready var story_label = %StoryLabel
@onready var proceed_button = %ProceedButton
@onready var passcode_input = get_node_or_null("%PasscodeInput")

var stories = {
	1: "=== SHIFT 1 COMPLETE ===\n\nCalibration complete.\n\nINCIDENT REPORT: Unit #3 (Walter) has broken containment locks and escaped into Sector B. Facility alert status raised to YELLOW.",
	2: "=== SHIFT 2 COMPLETE ===\n\nFacility Quarantine: CRITICAL.\n\nINCIDENT REPORT: Remote intrusions are escalating and containment breaches remain active. Sector B power grid unstable.",
	3: "=== SHIFT 3 COMPLETE ===\n\nPower Grid Sabotage Alert.\n\nINCIDENT REPORT: The Hunter has begun physically tripping breaker boxes. Circuit breaker resets required during outages.",
	4: "=== SHIFT 4 COMPLETE ===\n\nIdentity Verification Complete.\n\nINCIDENT REPORT: Employee records decrypted. Neural brain monitoring telemetry synchronized for Shift 5.",
	5: "=== SHIFT 5 COMPLETE - FINAL SHIFT ===\n\nProject Apparatus Unmasked.\n\nINCIDENT REPORT: You uncovered the truth behind Project Apparatus, survived all mimic intrusions, and maintained facility integrity through all 5 shifts.\n\nSector 4 containment holds. Campaign Complete."
}

var wishlist_popup: Control = null
var popup_blocker: ColorRect = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if has_node("CRTOverlay"):
		$CRTOverlay.visible = GameStats.crt_effect_enabled
	
	if passcode_input:
		passcode_input.visible = false
		
	var completed_day = GameStats.current_day - 1

	if GameStats.IS_DEMO and completed_day >= 2:
		_setup_demo_completion_screen(completed_day)
	else:
		_setup_standard_story_screen(completed_day)

func _setup_standard_story_screen(completed_day: int):
	if completed_day >= 5 or GameStats.is_victory:
		title_label.text = "Shift 5 Completed — Epilogue"
		story_label.text = stories.get(5, "Campaign Completed successfully.")
		proceed_button.text = "View Ending"
		proceed_button.pressed.connect(func():
			get_tree().paused = false
			GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")
		)
		return

	if completed_day in stories:
		title_label.text = "Shift " + str(completed_day) + " Completed"
		story_label.text = stories[completed_day]
		proceed_button.text = "Begin Shift " + str(completed_day + 1)
	else:
		title_label.text = "Shift Completed"
		story_label.text = "You have completed the shift successfully."
		proceed_button.text = "Next Day"
		
	proceed_button.pressed.connect(_on_proceed_pressed)

func _setup_demo_completion_screen(completed_day: int):
	title_label.text = "Shift 2 Completed (Demo)"
	story_label.text = stories.get(completed_day, "Shift 2 completed successfully.")
	
	proceed_button.text = "Return to Main Menu"
	proceed_button.pressed.connect(_on_main_menu_pressed)
	
	call_deferred("_show_wishlist_popup")

func _show_wishlist_popup():
	if wishlist_popup and wishlist_popup.visible:
		return

	# Modal Blocker Overlay
	if not popup_blocker:
		popup_blocker = ColorRect.new()
		popup_blocker.name = "WishlistPopupBlocker"
		popup_blocker.color = Color(0, 0, 0, 0.45)
		popup_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
		popup_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(popup_blocker)

	# Main Popup Window
	if not wishlist_popup:
		wishlist_popup = _create_wishlist_popup_window()
		add_child(wishlist_popup)
		get_viewport().size_changed.connect(_center_wishlist_popup)

	popup_blocker.visible = true
	wishlist_popup.visible = true
	_center_wishlist_popup()

	# Keep CRT overlay rendering over the popup
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		move_child(crt, get_child_count() - 1)

func _create_wishlist_popup_window() -> Control:
	var win = NinePatchRect.new()
	win.name = "WishlistPopup"
	var win_w: float = 480.0
	var win_h: float = 310.0
	win.custom_minimum_size = Vector2(win_w, win_h)
	win.size = Vector2(win_w, win_h)
	win.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	win.patch_margin_left = 12
	win.patch_margin_top = 12
	win.patch_margin_right = 12
	win.patch_margin_bottom = 12

	# Title Bar
	var title_bar = NinePatchRect.new()
	title_bar.name = "TitleBar"
	title_bar.position = Vector2(6, 6)
	title_bar.custom_minimum_size = Vector2(win_w - 12, 30)
	title_bar.size = Vector2(win_w - 12, 30)
	title_bar.texture = preload("res://RetroWindowsGUI/Window_Header.png")
	title_bar.region_rect = Rect2(0, 0, 48, 25)
	title_bar.patch_margin_left = 5
	title_bar.patch_margin_top = 3
	title_bar.patch_margin_right = 5
	title_bar.patch_margin_bottom = 3
	win.add_child(title_bar)

	var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	var frame_style = preload("res://RetroWindowsGUI/StyleBox_Inner_Frame.tres")

	# Title Text
	var title_lbl = Label.new()
	title_lbl.text = "Aethelgard OS — Demo Completed"
	title_lbl.position = Vector2(8, 5)
	title_lbl.add_theme_font_override("font", font_bold)
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title_bar.add_child(title_lbl)

	# Close [X] Button
	var close_btn = Button.new()
	close_btn.name = "CloseButton"
	close_btn.position = Vector2(win_w - 38, 4)
	close_btn.custom_minimum_size = Vector2(22, 22)
	close_btn.size = Vector2(22, 22)
	close_btn.icon = preload("res://RetroWindowsGUI/ExitButton.png")
	close_btn.expand_icon = true
	close_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_btn.add_theme_stylebox_override("normal", btn_normal)
	close_btn.add_theme_stylebox_override("hover", btn_hover)
	close_btn.add_theme_stylebox_override("pressed", btn_pressed)
	close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	close_btn.pressed.connect(_on_close_popup_pressed)
	title_bar.add_child(close_btn)

	# Inner Content Frame Panel
	var inner_panel = Panel.new()
	inner_panel.clip_contents = true
	inner_panel.position = Vector2(12, 40)
	inner_panel.size = Vector2(win_w - 24, 190)
	inner_panel.add_theme_stylebox_override("panel", frame_style)
	win.add_child(inner_panel)

	var inner_bg = ColorRect.new()
	inner_bg.color = Color(0.94, 0.94, 0.94, 1.0)
	inner_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner_panel.add_child(inner_bg)

	# Margin container to strictly contain text inside inner panel
	var margin_box = MarginContainer.new()
	margin_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_box.add_theme_constant_override("margin_left", 20)
	margin_box.add_theme_constant_override("margin_right", 20)
	margin_box.add_theme_constant_override("margin_top", 20)
	margin_box.add_theme_constant_override("margin_bottom", 16)
	inner_panel.add_child(margin_box)

	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 16)
	margin_box.add_child(content_vbox)

	# Heading inside content
	var heading = Label.new()
	heading.text = "★ DEMO COMPLETED ★"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", font_bold)
	heading.add_theme_font_size_override("font_size", 16)
	heading.add_theme_color_override("font_color", Color(0.0, 0.2, 0.5, 1.0))
	content_vbox.add_child(heading)

	# Body explanation
	var body = Label.new()
	body.text = "You have completed the first 2 shifts of Apparatus Inspector!\n\nWishlist the full game on Steam to uncover what happens in Shifts 3 through 7 upon release."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_override("font", font_regular)
	body.add_theme_font_size_override("font_size", 13)
	body.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1, 1.0))
	content_vbox.add_child(body)

	# Bottom Action Buttons Container
	var btn_hbox = HBoxContainer.new()
	btn_hbox.position = Vector2(12, 246)
	btn_hbox.size = Vector2(win_w - 24, 48)
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 16)
	win.add_child(btn_hbox)

	# Primary Button: "Wishlist on Steam"
	var wishlist_btn = Button.new()
	wishlist_btn.name = "WishlistOnSteamButton"
	wishlist_btn.text = "Wishlist on Steam"
	wishlist_btn.custom_minimum_size = Vector2(210, 44)
	wishlist_btn.add_theme_font_override("font", font_bold)
	wishlist_btn.add_theme_font_size_override("font_size", 14)
	wishlist_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	wishlist_btn.add_theme_color_override("font_hover_color", Color(0.1, 0.25, 0.6, 1))
	wishlist_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	wishlist_btn.add_theme_stylebox_override("normal", btn_normal)
	wishlist_btn.add_theme_stylebox_override("hover", btn_hover)
	wishlist_btn.add_theme_stylebox_override("pressed", btn_pressed)
	wishlist_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	wishlist_btn.pressed.connect(func():
		_on_wishlist_pressed()
		wishlist_btn.text = "Opened in Browser ✓"
	)
	btn_hbox.add_child(wishlist_btn)

	# Secondary Button: "Main Menu"
	var menu_btn = Button.new()
	menu_btn.name = "MainMenuButton"
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(150, 44)
	menu_btn.add_theme_font_override("font", font_bold)
	menu_btn.add_theme_font_size_override("font_size", 14)
	menu_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	menu_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	menu_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	menu_btn.add_theme_stylebox_override("normal", btn_normal)
	menu_btn.add_theme_stylebox_override("hover", btn_hover)
	menu_btn.add_theme_stylebox_override("pressed", btn_pressed)
	menu_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	menu_btn.pressed.connect(_on_main_menu_pressed)
	btn_hbox.add_child(menu_btn)

	return win

func _center_wishlist_popup():
	if wishlist_popup:
		var viewport_size = get_viewport_rect().size
		wishlist_popup.position.x = (viewport_size.x - wishlist_popup.size.x) / 2.0
		wishlist_popup.position.y = (viewport_size.y - wishlist_popup.size.y) / 2.0

func _on_close_popup_pressed():
	if wishlist_popup:
		wishlist_popup.visible = false
	if popup_blocker:
		popup_blocker.visible = false

func _on_wishlist_pressed():
	GameStats.open_steam_store()

func _on_main_menu_pressed():
	get_tree().paused = false
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/MainMenu.tscn")

func _on_proceed_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://Scenes/Game3D.tscn")
