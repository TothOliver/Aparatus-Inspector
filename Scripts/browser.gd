extends DesktopWindow

var current_url: String = "www.aparatusexplorer.net"
var history_back: Array = []
var history_forward: Array = []

var url_field: LineEdit
var content_label: RichTextLabel
var back_btn: Button
var forward_btn: Button

# 10 Website pages BBCode directory
var websites = {
	"www.aparatusexplorer.net": {
		"title": "Aparatus Explorer Network Portal",
		"content": "=== APARATUS EXPLORER PORTAL ===\n\nWelcome to the World Wide Web! This portal lists all websites currently online in the local network segment. Please verify your WiFi router signal before browsing.\n\n[b]Active Sites List:[/b]\n• [url=www.robot-factory.corp]Aparatus Robotics Factory[/url] - Official corporate page.\n• [url=www.inspections-database.org]Inspector Logs Database[/url] - Archives and reports.\n• [url=www.larry-shrine.fans]The Larry Fan Club[/url] - A shrine to model Larry.\n• [url=www.walter-files.com]The Walter Conspiracy[/url] - Underground whistleblower blog.\n• [url=www.weather-central.net]Local Weather Central[/url] - Meteorological service.\n• [url=www.retro-slots-cheats.info]Slots Strategy & Cheats[/url] - Double payout info.\n• [url=www.creepy-cryptid-forum.org]Vents & Vapors Discussion[/url] - Local forum.\n• [url=www.router-support.corp]NetGate Router Support[/url] - Device user manual.\n• [url=www.the-archivist.net]The Archivist's Diary[/url] - Personal notes."
	},
	"www.robot-factory.corp": {
		"title": "Aparatus Robotics - Building the Future",
		"content": "=== APARATUS ROBOTICS CORPORATION ===\n\nSafety, Efficiency, Compliance.\n\nAt Aparatus Robotics, we design state-of-the-art synthetic models to assist humanity. Our signature chassis models include the Larry social testbed and the Walter security frame.\n\nWe have recently passed 150 days without a major decommissioning accident! (Note: Any reports of rogue units crawling in ventilation systems are strictly rumors spread by disgruntled former inspectors.)\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.inspections-database.org": {
		"title": "Inspector Archives & Logs",
		"content": "=== ARCHIVE LOG #984 - CLASSIFIED ===\n\nSTATUS: DECOMMISSIONED\nInspector ID: 8872\nNotes: Unit showed signs of intense paranoia. Claimed that the security files 'classified_01' and 'classified_02' contained sensitive information about project Apparatus. Tried to decrypt them but couldn't find the encryption codes. If only he checked Walter's data...\n\n=== ARCHIVE LOG #985 ===\nInspector ID: 8873\nNotes: Safe, clean record. Terminated after failing to recognize a corrupted model that claimed to be 'innocent'.\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.larry-shrine.fans": {
		"title": "LARRY'S WORLD - Larry Fan Page",
		"content": "[color=red]❤❤❤ WELCOME TO LARRY'S SHRINE ❤❤❤[/color]\n\nLarry is the best robot model ever! He is so friendly and always tries to talk to the inspector. \n\nDid you know? In entry log #12, the author notes that Larry offered the inspector exactly [b]14[/b] dollars. Why 14? Some think it is a secret code! In fact, the local inspector discovered that the number [color=blue][b]14[/b][/color] is the [b]decryption key[/b] for the encrypted archive [color=green]classified_01.enc[/color]! Try typing `decrypt classified_01.enc 14` in your terminal.\n\nLARRY FOREVER!\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.walter-files.com": {
		"title": "The Walter Files - The Truth Out There",
		"content": "=== THE WALTER THREAT ===\n\nThey want you to think Walter is just a peaceful security frame. They are lying! \n\nWalter is the base chassis used by [color=red]The Hunter Robot[/color], a mechanical beast programmed to hunt and eliminate inspectors who know too much. The Hunter is blind in the dark; it cannot see you if the room lights and the PC screen are completely powered off.\n\nI found out that the code word [color=blue][b]walter[/b][/color] decrypts the file [color=green]classified_02.enc[/color] in the system terminal! Enter `decrypt classified_02.enc walter` to read the security warning yourself before it's too late.\n\nSTAY SAFE. STAY DARK.\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.weather-central.net": {
		"title": "Metro Weather Station",
		"content": "=== SOLAR ANOMALY WARNING ===\n\nThe weather radar is reporting severe electromagnetic spikes in the local area. This is causing significant power grid issues. Local offices may experience complete light blackouts. \n\nDuring blackouts, the power grid will reboot automatically when it reaches 10% charge. Keep your computer and office doors closed to conserve battery!\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.retro-slots-cheats.info": {
		"title": "Casino Slots Cheats & Tips",
		"content": "=== HOW TO BEAT THE CASINO APP ===\n\nThe slots application on the PC is rigged! But there are some hidden things in the code:\n• There is a 5% chance the reels will glitch and display the [color=red]ROBOT[/color] symbol across all three slots.\n• [b]WARNING:[/b] Spawning triple robots triggers the immediate deployment of the Hunter Robot. Do not spin unless you are prepared to hide under the desk!\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.creepy-cryptid-forum.org": {
		"title": "Local Area Cryptid Forum",
		"content": "=== VENTILATION NOISES ===\n\nUser_8832: 'Does anyone else hear clanking inside the vents at night?'\nUser_9921: 'Yes! It sounds like steel claws scraping. I think something is roaming around the corridors.'\nUser_1002: 'If you hear it coming, turn off your lights and hide. If it enters your room, crawl under the desk. The desk is a blind spot for its sensors! Don't move until it leaves.'\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.router-support.corp": {
		"title": "NetGate WiFi Router User Manual",
		"content": "=== NetGate Model NG-100 ===\n\nYour router on the desk provides network connectivity to the PC Explorer browser.\n\n• [color=green]Green LED[/color]: Router is ONLINE and transmitting internet traffic.\n• [color=red]Red LED[/color]: Router is OFFLINE. No external network traffic will load on the PC.\n\nTo toggle router power, click the physical button on top of the router device in the room.\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	},
	"www.the-archivist.net": {
		"title": "The Archivist's Diary",
		"content": "=== PERSONAL LOG ===\n\nI have hidden the decryption keys across these fan pages and conspiracy blogs where corporate won't look. The Larry shrine and the Walter files host the keys. \n\nIf you are reading this, the system is watching you. Keep your router on to gather information, but be ready to power off the monitor and hide when the metal scrapes.\n\n[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
	}
}

func _ready():
	is_scalable = true
	# Dynamically assemble the browser UI components inside this NinePatchRect window.
	custom_minimum_size = Vector2(500, 400)
	size = Vector2(500, 400)
	
	# Load retro styling resources
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	var inner_frame = preload("res://RetroWindowsGUI/StyleBox_Inner_Frame.tres")
	var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
	
	# Create Title Bar
	var title_bar_rect = NinePatchRect.new()
	title_bar_rect.name = "TitleBar"
	title_bar_rect.texture = preload("res://RetroWindowsGUI/Window_Header.png")
	title_bar_rect.region_rect = Rect2(0, 0, 48, 25)
	title_bar_rect.patch_margin_left = 5
	title_bar_rect.patch_margin_top = 3
	title_bar_rect.patch_margin_right = 5
	title_bar_rect.patch_margin_bottom = 3
	title_bar_rect.position = Vector2(6, 6)
	title_bar_rect.size = Vector2(488, 30)
	title_bar_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(title_bar_rect)
	
	# Manually set DesktopWindow reference to this TitleBar so dragging works
	title_bar = title_bar_rect
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	gui_input.connect(_on_window_gui_input)
	
	# Title bar icon
	var icon_rect = TextureRect.new()
	icon_rect.texture = load("res://Sprites/icon_browser.png")
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.position = Vector2(6, 6)
	icon_rect.size = Vector2(18, 18)
	title_bar_rect.add_child(icon_rect)
	
	# Title Label
	var title_lbl = Label.new()
	title_lbl.text = "Aparatus Explorer"
	title_lbl.add_theme_font_override("font", font_bold)
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.position = Vector2(30, 6)
	title_bar_rect.add_child(title_lbl)
	
	# Title bar Close button
	var close_btn = Button.new()
	close_btn.name = "CloseButton"
	close_btn.theme_type_variation = "FlatButton"
	close_btn.add_theme_stylebox_override("normal", btn_normal)
	close_btn.add_theme_stylebox_override("hover", btn_hover)
	close_btn.add_theme_stylebox_override("pressed", btn_pressed)
	close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	close_btn.icon = preload("res://RetroWindowsGUI/ExitButton.png")
	close_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_btn.position = Vector2(464, 6)
	close_btn.size = Vector2(18, 18)
	close_btn.pressed.connect(func(): close())
	title_bar_rect.add_child(close_btn)
	
	# Address bar container
	var addr_container = HBoxContainer.new()
	addr_container.position = Vector2(12, 42)
	addr_container.size = Vector2(476, 26)
	addr_container.add_theme_constant_override("separation", 6)
	add_child(addr_container)
	
	# Back Button
	back_btn = Button.new()
	back_btn.text = "<"
	back_btn.custom_minimum_size = Vector2(24, 24)
	back_btn.add_theme_font_override("font", font_bold)
	back_btn.add_theme_font_size_override("font_size", 10)
	back_btn.add_theme_color_override("font_color", Color(0,0,0,1))
	back_btn.add_theme_stylebox_override("normal", btn_normal)
	back_btn.add_theme_stylebox_override("hover", btn_hover)
	back_btn.add_theme_stylebox_override("pressed", btn_pressed)
	back_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	back_btn.pressed.connect(go_back)
	addr_container.add_child(back_btn)
	
	# Forward Button
	forward_btn = Button.new()
	forward_btn.text = ">"
	forward_btn.custom_minimum_size = Vector2(24, 24)
	forward_btn.add_theme_font_override("font", font_bold)
	forward_btn.add_theme_font_size_override("font_size", 10)
	forward_btn.add_theme_color_override("font_color", Color(0,0,0,1))
	forward_btn.add_theme_stylebox_override("normal", btn_normal)
	forward_btn.add_theme_stylebox_override("hover", btn_hover)
	forward_btn.add_theme_stylebox_override("pressed", btn_pressed)
	forward_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	forward_btn.pressed.connect(go_forward)
	addr_container.add_child(forward_btn)
	
	# Home Button
	var home_btn = Button.new()
	home_btn.text = "Home"
	home_btn.custom_minimum_size = Vector2(45, 24)
	home_btn.add_theme_font_override("font", font_regular)
	home_btn.add_theme_font_size_override("font_size", 10)
	home_btn.add_theme_color_override("font_color", Color(0,0,0,1))
	home_btn.add_theme_stylebox_override("normal", btn_normal)
	home_btn.add_theme_stylebox_override("hover", btn_hover)
	home_btn.add_theme_stylebox_override("pressed", btn_pressed)
	home_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	home_btn.pressed.connect(go_home)
	addr_container.add_child(home_btn)
	
	# Address Input LineEdit
	url_field = LineEdit.new()
	url_field.text = current_url
	url_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	url_field.add_theme_font_override("font", font_regular)
	url_field.add_theme_font_size_override("font_size", 12)
	url_field.add_theme_color_override("font_color", Color(0,0,0,1))
	url_field.add_theme_stylebox_override("normal", inner_frame)
	url_field.text_submitted.connect(on_url_submitted)
	addr_container.add_child(url_field)
	
	# Go Button
	var go_btn = Button.new()
	go_btn.text = "Go"
	go_btn.custom_minimum_size = Vector2(35, 24)
	go_btn.add_theme_font_override("font", font_regular)
	go_btn.add_theme_font_size_override("font_size", 10)
	go_btn.add_theme_color_override("font_color", Color(0,0,0,1))
	go_btn.add_theme_stylebox_override("normal", btn_normal)
	go_btn.add_theme_stylebox_override("hover", btn_hover)
	go_btn.add_theme_stylebox_override("pressed", btn_pressed)
	go_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	go_btn.pressed.connect(func(): on_url_submitted(url_field.text))
	addr_container.add_child(go_btn)
	
	# Content Border Panel
	var content_panel = Panel.new()
	content_panel.position = Vector2(12, 74)
	content_panel.size = Vector2(476, 314)
	content_panel.add_theme_stylebox_override("panel", inner_frame)
	add_child(content_panel)
	
	# Scroll Container
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 8
	scroll.offset_top = 8
	scroll.offset_right = -8
	scroll.offset_bottom = -8
	content_panel.add_child(scroll)
	
	# RichTextLabel
	content_label = RichTextLabel.new()
	content_label.bbcode_enabled = true
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_label.custom_minimum_size = Vector2(200, 200)
	content_label.add_theme_font_override("normal_font", font_regular)
	content_label.add_theme_font_override("bold_font", font_bold)
	content_label.add_theme_font_size_override("normal_font_size", 12)
	content_label.add_theme_font_size_override("bold_font_size", 12)
	content_label.add_theme_color_override("default_color", Color(0, 0, 0, 1))
	content_label.add_theme_color_override("hyperlink_color", Color(0, 0, 0.8, 1))
	content_label.meta_clicked.connect(on_link_clicked)
	scroll.add_child(content_label)
	
	# Initial navigation load
	_load_current_page(false)

func navigate_to(url: String, record_history: bool = true):
	var target = url.strip_edges().to_lower()
	if not target.begins_with("www."):
		target = "www." + target
		
	if record_history and current_url != "":
		history_back.append(current_url)
		history_forward.clear()
		
	current_url = target
	_load_current_page(record_history)

func _load_current_page(update_history_buttons: bool = true):
	if url_field:
		url_field.text = current_url
		
	# Check WiFi connection
	if not GameStats.wifi_on:
		content_label.text = "[color=red][b]Server Not Found[/b][/color]\n\n" + \
			"Aparatus Explorer cannot connect to the server at this address. The server might be temporarily down or you are disconnected from the network.\n\n" + \
			"[b]Diagnostic Suggestions:[/b]\n" + \
			"1. Verify that your physical WiFi Router's power light is glowing [color=green]Green[/color].\n" + \
			"2. If the light is [color=red]Red[/color], press the physical button on top of the router in the room to power it back on.\n" + \
			"3. Retry navigating to the website after network connection is restored."
	elif websites.has(current_url):
		var site = websites[current_url]
		content_label.text = "[font_size=16][b]" + site["title"] + "[/b][/font_size]\n\n" + site["content"]
	else:
		content_label.text = "[color=darkred][b]404 Page Not Found[/b][/color]\n\n" + \
			"The requested URL '" + current_url + "' could not be found on this server. Please check the spelling and try again.\n\n" + \
			"[url=www.aparatusexplorer.net]<< Return to Web Portal[/url]"
			
	# Update back/forward button states
	if back_btn:
		back_btn.disabled = history_back.size() == 0
	if forward_btn:
		forward_btn.disabled = history_forward.size() == 0

func go_back():
	if history_back.size() > 0:
		history_forward.append(current_url)
		current_url = history_back.pop_back()
		_load_current_page(false)

func go_forward():
	if history_forward.size() > 0:
		history_back.append(current_url)
		current_url = history_forward.pop_back()
		_load_current_page(false)

func go_home():
	navigate_to("www.aparatusexplorer.net")

func on_url_submitted(new_url: String):
	if new_url.strip_edges() != "":
		navigate_to(new_url)

func on_link_clicked(meta):
	var url_str = str(meta)
	navigate_to(url_str)
