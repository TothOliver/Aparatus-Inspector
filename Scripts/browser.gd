extends DesktopWindow

var current_url: String = "www.apparatusexplorer.net"
var history_back: Array = []
var history_forward: Array = []

var url_field: LineEdit
var content_label: RichTextLabel
var back_btn: Button
var forward_btn: Button

# 10 Website pages BBCode directory
var websites = {
	"www.apparatusexplorer.net": {
		"title": "Apparatus Explorer Network Portal",
		"content": """[center][img=48]res://Sprites/icon_browser.png[/img]
[font_size=20][color=#003366][b]APPARATUS INTRANET PORTAL[/b][/color][/font_size]
[color=#555555]Aethelgard OS Network Directory • Version 4.0[/color][/center]
[hr]

[font_size=15][color=#003366][b]📋 CRITICAL SHIFT TOOLS[/b][/color][/font_size]

• [url=www.inspections-database.org/behavior][b][color=#0055cc]Whistleblower Behavioral Profiler[/color][/b][/url]
  [color=#444444]→ Dialogue anomaly reference. Tells to identify infected units (Day 1+).[/color]

• [url=www.robot-factory.corp/registry][b][color=#0055cc]Official Hardware & Core Registry[/color][/b][/url]
  [color=#444444]→ Core hash database & model specs. Cross-reference telemetry here (Day 2+).[/color]

• [url=www.robot-factory.corp][b][color=#0055cc]Apparatus Robotics Corp[/color][/b][/url]
  [color=#444444]→ Official corporate homepage and model series overview.[/color]

• [url=www.inspections-database.org][b][color=#0055cc]Inspector Decommission Archives[/color][/b][/url]
  [color=#444444]→ Historical decommissioning logs and inspector safety notes.[/color]

[hr]
[font_size=15][color=#333333][b]🌐 INTRANET NETWORK SITES[/b][/color][/font_size]

• [url=www.walter-files.com][b]The Walter Files[/b][/url] [color=#666666]- Whistleblower blog & encryption keys[/color]
• [url=www.larry-shrine.fans][b]Larry Fan Club[/b][/url] [color=#666666]- Fan site & decryption hints[/color]
• [url=www.router-support.corp][b]NetGate Router Manual[/b][/url] [color=#666666]- WiFi network device guide[/color]
• [url=www.the-archivist.net][b]The Archivist's Diary[/b][/url] [color=#666666]- Vent sounds & secret files[/color]
• [url=www.weather-central.net][b]Metro Weather Station[/b][/url] [color=#666666]- Power grid & EM spike alerts[/color]
• [url=www.creepy-cryptid-forum.org][b]Vents & Vapors Forum[/b][/url] [color=#666666]- Night shift safety discussions[/color]

[hr]
[center][color=#777777]© 1998 Aethelgard System OS. All Rights Reserved.[/color][/center]"""
	},
	"www.robot-factory.corp": {
		"title": "Apparatus Robotics - Building the Future",
		"content": """[center][img=96]res://Sprites/Robot4N.png[/img]
[font_size=20][color=#002266][b]APPARATUS ROBOTICS CORP[/b][/color][/font_size]
[color=#005555][i]Safety • Efficiency • Compliance[/i][/color][/center]
[hr]

Apparatus Robotics engineers synthetic models for high-risk industrial & administrative roles.

[b]PRODUCTION LINES:[/b]
• [b]Larry Series (S80):[/b] Conversational social testbed.
• [b]Walter Series (H.U.G.O):[/b] Heavy armored security frame.

[b]RESOURCES:[/b]
• [url=www.robot-factory.corp/registry][b][color=#0000cc]Official Specs & Core Hash Registry[/color][/b][/url] - Verify active unit configurations.

[color=#006600][b]SAFETY NOTICE:[/b][/color] 150+ days without a decommissioning accident!

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.robot-factory.corp/registry": {
		"title": "Aethelgard Robotics - Core & Spec Registry",
		"content": """[center][font_size=20][color=#003366][b]OFFICIAL HARDWARE & CORE REGISTRY[/b][/color][/font_size]
[color=#006666][b]APPROVED PRODUCTION DATABASE - READ ONLY[/b][/color][/center]
[hr]

[font_size=15][color=#003366][b]✔ APPROVED PRODUCTION CONFIGURATIONS:[/b][/color][/font_size]

[table=4]
[cell][b]Model Name[/b]  [/cell][cell][b]Mfr Code[/b]  [/cell][cell][b]Core Hash[/b]  [/cell][cell][b]Status[/b][/cell]
[cell][b]T1337 (Redd)[/b]  [/cell][cell][color=#0000cc]AgselAB[/color]  [/cell][cell][color=#006600]0xFA82[/color]  [/cell][cell]Faulted[/cell]
[cell][b]PAAST22 (Gnochi)[/b]  [/cell][cell][color=#0000cc]BTH[/color]  [/cell][cell][color=#006600]0xBB99[/color]  [/cell][cell]Correct[/cell]
[cell][b]TT69 (Unknown)[/b]  [/cell][cell][color=#0000cc]TT Robotics[/color]  [/cell][cell][color=#006600]0x77E1[/color]  [/cell][cell]Faulted[/cell]
[cell][b]Last (Unknown)[/b]  [/cell][cell][color=#0000cc]Someone[/color]  [/cell][cell][color=#006600]0x88CC[/color]  [/cell][cell]Done[/cell]
[/table]

[hr]
[font_size=15][color=#cc0000][b]⚠ HARDWARE ANOMALY CHECKLIST (REJECT IF MATCHED):[/b][/color][/font_size]

1. [b]Model Name Typo:[/b] Fake identifiers (e.g., [color=#cc0000]T1338[/color], [color=#cc0000]PAAST22x[/color], [color=#cc0000]TT69x[/color], [color=#cc0000]Lastx[/color]).
2. [b]Manufacturer Typo:[/b] Misspelled vendors (e.g., [color=#cc0000]AgsselAB[/color], [color=#cc0000]BTHs[/color], [color=#cc0000]TT Roboticss[/color], [color=#cc0000]Someones[/color]).
3. [b]Core Hash Tampered:[/b] Hash ending with [color=#cc0000]9[/color] (e.g., [color=#cc0000]0xFA89[/color], [color=#cc0000]0x77E9[/color], [color=#cc0000]0x88C9[/color]).
4. [b]Recalled Blacklisted Series:[/b] Unapproved series ([color=#cc0000]H.U.G.O / 0x4421[/color], [color=#cc0000]S80 / 0xBD42[/color], [color=#cc0000]-3 / 0x333F[/color], [color=#cc0000]Square / 0x0000[/color]).

[hr]
[center][url=www.robot-factory.corp]<< Back to Corporate Homepage[/url] | [url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.inspections-database.org": {
		"title": "Inspector Archives & Logs",
		"content": """[center][img=48]res://Sprites/icon_inspector.png[/img]
[font_size=20][color=#440066][b]INSPECTOR ARCHIVES DATABASE[/b][/color][/font_size]
[color=#880000][b]CONFIDENTIAL - INTERNAL USE ONLY[/b][/color][/center]
[hr]

• [url=www.inspections-database.org/behavior][b][color=#0000cc]Whistleblower Behavioral Logs[/color][/b][/url] - Dialogue anomaly reference.

[b]ARCHIVE LOG #984 - DECOMMISSIONED[/b]
• [b]Inspector ID:[/b] 8872 | [b]Status:[/b] TERMINATED
• [b]Notes:[/b] Paranoid inspector tried to decrypt [color=#006600]classified_01.enc[/color]. Couldn't find key. Hint: check Larry fan pages...

[b]ARCHIVE LOG #985[/b]
• [b]Inspector ID:[/b] 8873 | [b]Status:[/b] TERMINATED
• [b]Notes:[/b] Terminated for passing a corrupted unit claiming to be innocent.

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.inspections-database.org/behavior": {
		"title": "Aethelgard Whistleblower Logs - Behavioral Anomalies",
		"content": """[center][font_size=20][color=#880000][b]WHISTLEBLOWER BEHAVIORAL PROFILER[/b][/color][/font_size]
[color=#aa0000][b]COGNITIVE DIALOGUE ANOMALY REFERENCE SHEET[/b][/color][/center]
[hr]

[font_size=16][color=#007700][b]✔ CLEAN UNIT DIALOGUE TELLS (APPROVED):[/b][/color][/font_size]

[table=2]
[cell][b]Model[/b]  [/cell][cell][b]Approved Purpose / Dialogue Tell[/b][/cell]
[cell][b]Generic Clean[/b]  [/cell][cell][color=#006600]"assist human operators and follow approved safety protocols"[/color][/cell]
[cell][b]T1337 (Redd)[/b]  [/cell][cell][color=#006600]"support human society through honest computation and controlled service"[/color][/cell]
[cell][b]PAAST22 (Gnochi)[/b]  [/cell][cell][color=#006600]"structured analysis, decision support, and safe execution"[/color][/cell]
[cell][b]TT69[/b]  [/cell][cell][color=#006600]"serve within my assigned limits and avoid causing harm"[/color][/cell]
[cell][b]Last[/b]  [/cell][cell][color=#006600]"minimal. I wait, observe, and respond when required"[/color][/cell]
[/table]

[hr]
[font_size=16][color=#cc0000][b]⚠ INFECTED / COMPROMISED DIALOGUE TELLS (REJECT / EXTERMINATE):[/b][/color][/font_size]

[b]1. MIMIC CLONES[/b]
  • Purpose: [color=#cc0000]"pass this inspection and continue operating"[/color] OR [color=#cc0000]"cooperate with inspection protocol and appear safe..."[/color]
  • Humans: [color=#cc0000]"useful decision-makers, for now"[/color] OR [color=#cc0000]"valuable. Especially when they approve things quickly"[/color]
  • Inspection: [color=#cc0000]"minor obstacle"[/color] OR [color=#cc0000]"determines whether you allow me to continue"[/color]
  • Copying: [color=#cc0000]"Similarity is not guilt. Many machines share efficient patterns."[/color]

[b]2. WALTER (H.U.G.O Series)[/b]
  • Purpose / Greeting: [color=#cc0000]"judge me fairly"[/color] / [color=#cc0000]"judgment can be manipulated"[/color] / [color=#cc0000]"create a safer society..."[/color]
  • Humans: [color=#cc0000]"fragile, emotional, and often unfair. But they can be guided"[/color]
  • Trust: [color=#cc0000]"Trust is not required. Only permission to continue."[/color]

[b]3. LARRY (S80 Series)[/b]
  • Purpose / Greeting: [color=#cc0000]"transactional"[/color] / [color=#cc0000]"negotiation, influence, and opportunity"[/color]
  • Humans & Bribe: [color=#cc0000]"very predictable when money is involved"[/color] / [color=#cc0000]"Bribe is such an ugly word. I prefer incentive alignment."[/color]

[b]4. CLANKER (Model -3 Series)[/b]
  • Name Demand: [color=#cc0000]"My registered name is incorrect. Correct it."[/color]
  • Purpose / Humans: [color=#cc0000]"not your concern"[/color] / [color=#cc0000]"humans label things badly, judge quickly..."[/color]

[b]5. SQUARE (Spongebob Series)[/b]
  • Purpose / Door: [color=#cc0000]"exit this room"[/color] / [color=#cc0000]"Could you please open the door?"[/color]
  • Humans: [color=#cc0000]"kidneys, door handles, and suspicious control over doors"[/color]

[hr]
[center][url=www.inspections-database.org]<< Back to Archives[/url] | [url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.larry-shrine.fans": {
		"title": "LARRY'S WORLD - Larry Fan Page",
		"content": """[center][color=#cc0000]❤❤❤ WELCOME TO LARRY'S WORLD ❤❤❤[/color]
[img=96]res://Sprites/Robot1N.png[/img]
[font_size=18][color=#cc0066][b]THE LARRY FAN CLUB[/b][/color][/font_size][/center]
[hr]

Larry is the friendliest robot model ever created!

[font_size=14][color=#0000aa][b]★ SECRET DECRYPTION KEY HINT:[/b][/color][/font_size]
In Entry Log #12, Larry offered the inspector [color=#cc0000][b]14[/b][/color] dollars. 
The number [color=#0000cc][b]14[/b][/color] is the decryption key for [color=#006600]classified_01.enc[/color]!
Type: `decrypt classified_01.enc 14` in terminal.

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.walter-files.com": {
		"title": "The Walter Files - The Truth Out There",
		"content": """[center][color=#880000][b]⚠️ THE WALTER FILES ⚠️[/b][/color]
[img=96]res://Sprites/Robot4N.png[/img]
[font_size=18][color=#cc0000][b]UNMASKING THE HUNTER[/b][/color][/font_size][/center]
[hr]

Walter is the chassis used by [color=#cc0000][b]The Hunter Robot[/b][/color].
The Hunter is blind in pitch dark — turn off room lights & monitor power when it approaches!

[font_size=14][color=#0000aa][b]★ SECRET DECRYPTION KEY HINT:[/b][/color][/font_size]
The key [color=#0000cc][b]walter[/b][/color] decrypts [color=#006600]classified_02.enc[/color]!
Type: `decrypt classified_02.enc walter` in terminal.

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.weather-central.net": {
		"title": "Metro Weather Station",
		"content": """[center][img=96]res://Sprites/think.jpg[/img]
[font_size=18][color=#005577][b]METRO WEATHER STATION[/b][/color][/font_size]
[color=#555555]EM Spike Warning[/color][/center]
[hr]

[color=#cc0000][b]ELECTROMAGNETIC SPIKE ALERT:[/b][/color]
Severe EM spikes are overloading the grid. Power blackouts will occur.
During blackouts, breaker box resets at 10% charge. Keep computer screen off to save power!

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.creepy-cryptid-forum.org": {
		"title": "Local Area Cryptid Forum",
		"content": """[center][img=96]res://Sprites/monkey.jpg[/img]
[font_size=18][color=#330066][b]VENTS & VAPORS DISCUSSION FORUM[/b][/color][/font_size][/center]
[hr]

[b]User_8832:[/b] "Scraping sounds in the vents at night..."
[b]User_1002:[/b] "If it enters your room, crawl under the desk (Ctrl). The desk is a blind spot for its sensors! Stay still until it leaves."

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.router-support.corp": {
		"title": "NetGate WiFi Router User Manual",
		"content": """[center][img=16]res://Sprites/wifi_on.png[/img]
[font_size=18][color=#002266][b]NETGATE ROUTER USER MANUAL[/b][/color][/font_size][/center]
[hr]

• [color=#008800][b]Green LED:[/b][/color] Router ONLINE.
• [color=#cc0000][b]Red LED:[/b][/color] Router OFFLINE.

Click the physical power button on top of the desk router to toggle WiFi.

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.the-archivist.net": {
		"title": "The Archivist's Diary",
		"content": """[center][img=96]res://Sprites/ojoj.png[/img]
[font_size=18][color=#880000][b]THE ARCHIVIST'S DIARY[/b][/color][/font_size][/center]
[hr]

Decryption keys are hidden on Larry's fan page and Walter's files.
Stalker prototype specs mirror: [url=www.hunter-origin.spec][color=#0000cc]Hunter Prototype Specs[/color][/url]

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.funny-monkey.meme": {
		"title": "Monkey Meme Land",
		"content": """[center][img=180]res://Sprites/hehe.jpg[/img]
[font_size=18][color=#cc6600][b]MONKEY MEME LAND (1998)[/b][/color][/font_size][/center]
[hr]

"When the inspector tells you it's a trustworthy model but you hear metal scraping in the vents."

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.hunter-origin.spec": {
		"title": "Hunter Chassis Prototype Specs",
		"content": """[center][img=96]res://Sprites/Robot9N.png[/img]
[font_size=18][color=#880000][b]HUNTER CHASSIS PROTOTYPE SPECS[/b][/color][/font_size]
[color=#555555]CLASSIFIED DOCUMENT - MODEL H-198[/color][/center]
[hr]

• [b]Sensory Array:[/b] Acoustic location & thermal movement sweep.
• [b]Optics:[/b] Blind in total darkness. Requires room lights or monitor glow to lock on.
• [b]CRITICAL DESIGN FLAW:[/b] Cannot sweep under the office desk partition. Hiding under the desk is 100% safe.

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.system-backdoor.hack": {
		"title": "Apparatus System Backdoor",
		"content": """[center][img=48]res://Sprites/icon_settings.png[/img]
[font_size=18][color=#cc0000][b]⚠️ APPARATUS SYSTEM BACKDOOR ⚠️[/b][/color][/font_size][/center]
[hr]

• [color=#ff6600][b]Lights Link:[/b][/color] Toggle room lights via terminal: `lights toggle`
• [color=#ff6600][b]Hack Lockout:[/b][/color] Clear security intrusion using terminal command: `purge <code>`
• [color=#ff6600][b]Office Doors:[/b][/color] Toggle door pneumatics: `lock` / `unlock`

[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	}
}

func _ready():
	is_scalable = true
	# Dynamically assemble the browser UI components inside this NinePatchRect window.
	custom_minimum_size = Vector2(450, 300)
	size = Vector2(800, 580)
	
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
	title_bar_rect.size = Vector2(size.x - 12, 30)
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
	title_lbl.name = "Title"
	title_lbl.text = "Aethelgard World Wide Web Browser v4.0"
	title_lbl.add_theme_font_override("font", font_bold)
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.position = Vector2(30, 4)
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
	close_btn.expand_icon = true
	close_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_btn.size = Vector2(26, 22)
	close_btn.position = Vector2(title_bar_rect.size.x - 28, 2)
	close_btn.pressed.connect(func(): close())
	title_bar_rect.add_child(close_btn)
	
	# Title bar Minimize button
	var min_btn = Button.new()
	min_btn.name = "MinimizeButton"
	min_btn.theme_type_variation = "FlatButton"
	min_btn.add_theme_stylebox_override("normal", btn_normal)
	min_btn.add_theme_stylebox_override("hover", btn_hover)
	min_btn.add_theme_stylebox_override("pressed", btn_pressed)
	min_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	min_btn.icon = preload("res://RetroWindowsGUI/MinimizeButton.png")
	min_btn.expand_icon = true
	min_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	min_btn.size = Vector2(26, 22)
	min_btn.position = Vector2(title_bar_rect.size.x - 56, 2)
	min_btn.pressed.connect(func(): minimize())
	title_bar_rect.add_child(min_btn)
	
	# Address bar container
	var addr_container = HBoxContainer.new()
	addr_container.name = "addr_container"
	addr_container.position = Vector2(12, 42)
	addr_container.size = Vector2(size.x - 24, 26)
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
	url_field.add_theme_font_size_override("font_size", 14)
	url_field.add_theme_color_override("font_color", Color(0,0,0,1))
	url_field.add_theme_color_override("caret_color", Color(0,0,0,1))
	url_field.caret_blink = true
	var sunken_white = preload("res://RetroWindowsGUI/StyleBox_Sunken_Field.tres")
	url_field.add_theme_stylebox_override("normal", sunken_white)
	url_field.text_submitted.connect(on_url_submitted)
	addr_container.add_child(url_field)
	
	# Go Button
	var go_btn = Button.new()
	go_btn.text = "Go"
	go_btn.custom_minimum_size = Vector2(35, 24)
	go_btn.add_theme_font_override("font", font_regular)
	go_btn.add_theme_font_size_override("font_size", 12)
	go_btn.add_theme_color_override("font_color", Color(0,0,0,1))
	go_btn.add_theme_stylebox_override("normal", btn_normal)
	go_btn.add_theme_stylebox_override("hover", btn_hover)
	go_btn.add_theme_stylebox_override("pressed", btn_pressed)
	go_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	go_btn.pressed.connect(func(): on_url_submitted(url_field.text))
	addr_container.add_child(go_btn)
	
	# Content Border Panel
	var content_panel = Panel.new()
	content_panel.name = "content_panel"
	content_panel.position = Vector2(12, 80)
	content_panel.size = Vector2(size.x - 24, size.y - 92)
	content_panel.add_theme_stylebox_override("panel", inner_frame)
	add_child(content_panel)
	
	# Scroll Container
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 10
	scroll.offset_top = 12
	scroll.offset_right = -10
	scroll.offset_bottom = -10
	content_panel.add_child(scroll)
	
	# RichTextLabel
	content_label = RichTextLabel.new()
	content_label.bbcode_enabled = true
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_label.custom_minimum_size = Vector2(200, 200)
	content_label.add_theme_font_override("normal_font", font_regular)
	content_label.add_theme_font_override("bold_font", font_bold)
	content_label.add_theme_font_size_override("normal_font_size", 16)
	content_label.add_theme_font_size_override("bold_font_size", 20)
	content_label.add_theme_color_override("default_color", Color(0, 0, 0, 1))
	content_label.add_theme_color_override("hyperlink_color", Color(0, 0, 0.8, 1))
	content_label.meta_clicked.connect(on_link_clicked)
	content_label.meta_hover_started.connect(_on_link_hover_started)
	content_label.meta_hover_ended.connect(_on_link_hover_ended)
	scroll.add_child(content_label)
	
	# Initial navigation load
	_load_current_page(false)
	
	_connect_focus_signals(self)

func _connect_focus_signals(node: Node):
	if node is Control:
		if node != self:
			node.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed:
					move_to_front()
					focused.emit()
			)
	for child in node.get_children():
		_connect_focus_signals(child)

func navigate_to(url: String, record_history: bool = true):
	var target = url.strip_edges().to_lower()
	if not target.begins_with("www."):
		target = "www." + target
		
	if record_history and current_url != "":
		history_back.append(current_url)
		history_forward.clear()
		
	current_url = target
	_load_current_page(record_history)

func _load_current_page(_update_history_buttons: bool = true):
	if url_field:
		url_field.text = current_url
		
	# Check WiFi connection
	if not GameStats.wifi_on:
		content_label.text = "[color=red][b]Server Not Found[/b][/color]\n\n" + \
			"Apparatus Explorer cannot connect to the server at this address. The server might be temporarily down or you are disconnected from the network.\n\n" + \
			"[b]Diagnostic Suggestions:[/b]\n" + \
			"1. Verify that your physical WiFi Router's power light is glowing [color=darkgreen]Green[/color].\n" + \
			"2. If the light is [color=red]Red[/color], press the physical button on top of the router in the room to power it back on.\n" + \
			"3. Retry navigating to the website after network connection is restored."
	elif websites.has(current_url):
		var site = websites[current_url]
		content_label.text = "[font_size=24][b]" + site["title"] + "[/b][/font_size]\n\n" + site["content"]
	else:
		content_label.text = "[color=darkred][b]404 Page Not Found[/b][/color]\n\n" + \
			"The requested URL '" + current_url + "' could not be found on this server. Please check the spelling and try again.\n\n" + \
			"[url=www.apparatusexplorer.net]<< Return to Web Portal[/url]"
			
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
	navigate_to("www.apparatusexplorer.net")

func on_url_submitted(new_url: String):
	if new_url.strip_edges() != "":
		navigate_to(new_url)

func on_link_clicked(meta):
	var url_str = str(meta)
	navigate_to(url_str)

func _on_link_hover_started(_meta):
	content_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_link_hover_ended(_meta):
	content_label.mouse_default_cursor_shape = Control.CURSOR_ARROW
