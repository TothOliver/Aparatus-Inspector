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
[font_size=16][color=navy][b]APPARATUS NET FINDER[/b][/color][/font_size]
[color=#333333]Your Gateway to the Intranet • Ver 1.0b[/color][/center]
[hr]
Welcome to the Apparatus Explorer Portal! This portal index lists all active web servers running on the local network segment. Please verify your NetGate wifi router connection before browsing.

[b]Web Directories & Resources:[/b]
[indent]
• [url=www.robot-factory.corp]Apparatus Robotics Corp[/url] - Official corporate homepage and model schematics.
• [url=www.robot-factory.corp/registry]Official Specs & Core Registry[/url] - Core hash database specs.
• [url=www.inspections-database.org]Inspector Logs Database[/url] - Decommissioning reports and safety archives.
• [url=www.inspections-database.org/behavior]Whistleblower Behavioral Logs[/url] - Anomaly detection tells database.
• [url=www.larry-shrine.fans]The Larry Fan Club[/url] - A fan-operated shrine to the friendly Larry model.
• [url=www.walter-files.com]The Walter Conspiracy[/url] - Whistleblower blog about security frame anomalies.
• [url=www.weather-central.net]Local Weather Central[/url] - Meteorological warning and satellite radar map.
• [url=www.retro-slots-cheats.info]Slots Strategy & Cheats[/url] - Secret payout tips for the terminal slots software.
• [url=www.creepy-cryptid-forum.org]Vents & Vapors Discussion[/url] - Local forum discussing vent noises and sightings.
• [url=www.router-support.corp]NetGate Router Support[/url] - Network device manuals and troubleshooting guides.
• [url=www.the-archivist.net]The Archivist's Diary[/url] - Glitched personal logs and notes.
[/indent]
[hr]
[center][color=#333333]© 1998 Apparatus Corporation. All Rights Reserved.[/color][/center]"""
	},
	"www.robot-factory.corp": {
		"title": "Apparatus Robotics - Building the Future",
		"content": """[center][img=128]res://Sprites/robot4.png[/img]
[font_size=16][color=darkblue][b]APPARATUS ROBOTICS[/b][/color][/font_size]
[color=teal][i]Safety • Efficiency • Compliance[/i][/color][/center]
[hr]
At Apparatus Robotics, we engineer state-of-the-art synthetic models to assist humanity in high-risk environments. Our signature chassis models include the [b]Larry[/b] social testbed and the [b]Walter[/b] security frame.

[b]Current Production Lines:[/b]
• [b]Larry series[/b]: Highly empathetic conversational units designed for administrative roles.
• [b]Walter series[/b]: Robust armored mechanical frames designed for security patrol.

[color=green][b]DIAGNOSTIC RESOURCES:[/b][/color]
• [url=www.robot-factory.corp/registry]Official Specs & Core Hash Registry[/url] - Verify active unit configurations.

[color=green][b]SAFETY NOTICE:[/b][/color] We have recently passed 150 days without a decommissioning accident! 
[i](Note: Any rumors regarding rogue units crawling inside the ventilation shafts are strictly corporate sabotage spread by disgruntled former inspectors.)[/i]
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.robot-factory.corp/registry": {
		"title": "Aethelgard Robotics - Core & Spec Registry",
		"content": """[center][font_size=16][color=darkblue][b]OFFICIAL SPECIFICATIONS REGISTRY[/b][/color][/font_size]
[color=teal][b]SECURE SERVER - READ-ONLY[/b][/color][/center]
[hr]
Use this registry to verify active robot specs. If a unit's specs or core signature do not match the database, it has been compromised by the Prime-0 network worm and must be [color=red][b]EXTERMINATED[/b][/color].

[b]Approved Production Configurations:[/b]
[indent]
• [b]T1337 (T-Series "Redd")[/b]:
  - Manufacturer: [color=blue]AgselAB[/color]
  - Valid Core Hash: [color=green]0xFA82[/color]
  - Standard Status: Faulted
• [b]PAAST22 (PAAST-Series "Gnochi")[/b]:
  - Manufacturer: [color=blue]BTH[/color]
  - Valid Core Hash: [color=green]0xBB99[/color]
  - Standard Status: Correct
• [b]TT69 (TT-Series "Unknown")[/b]:
  - Manufacturer: [color=blue]TT Robotics[/color]
  - Valid Core Hash: [color=green]0x77E1[/color]
  - Standard Status: Faulted
• [b]Last (Someone-Series "Unknown")[/b]:
  - Manufacturer: [color=blue]Someone[/color]
  - Valid Core Hash: [color=green]0x88CC[/color]
  - Standard Status: Done
[/indent]

[b]Unregistered Models & Series:[/b]
Any unit displaying models not listed here (e.g. [i]H.A.R.O.L.D[/i], [i]S80[/i], [i]H.U.G.O[/i]) or containing spelling mistakes (e.g. [i]AgsselAB[/i], [i]T1338[/i]) is unauthorized. 

[i]Security Advisory: Walter series (H.U.G.O) and Larry series (S80) were recalled due to severe network worm susceptibility. Do not trust their diagnostics or speech patterns.[/i]
[hr]
[center][url=www.robot-factory.corp]<< Back to Homepage[/url] | [url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.inspections-database.org": {
		"title": "Inspector Archives & Logs",
		"content": """[center][img=48]res://Sprites/icon_inspector.png[/img]
[font_size=16][color=purple][b]INSPECTOR ARCHIVES DATABASE[/b][/color][/font_size]
[color=darkred][b]CONFIDENTIAL - INTERNAL USE ONLY[/b][/color][/center]
[hr]
[b]ADDITIONAL ARCHIVE DIAGNOSTICS:[/b]
• [url=www.inspections-database.org/behavior]Whistleblower Behavioral Logs[/url] - Review model cognitive anomaly markers.

[b]ARCHIVE LOG #984 - DECOMMISSIONED[/b]
• [b]Inspector ID[/b]: 8872
• [b]Decommission Status[/b]: TERMINATED
• [b]Notes[/b]: Unit showed signs of intense paranoia. Claimed that the security files 'classified_01' and 'classified_02' contained sensitive information about project Apparatus. Tried to decrypt them but couldn't find the encryption codes. If only he checked Walter's data...

[b]ARCHIVE LOG #985[/b]
• [b]Inspector ID[/b]: 8873
• [b]Decommission Status[/b]: TERMINATED
• [b]Notes[/b]: Safe, clean record. Terminated after failing to recognize a corrupted model that claimed to be 'innocent'.
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.inspections-database.org/behavior": {
		"title": "Aethelgard Whistleblower Logs - Behavioral Anomalies",
		"content": """[center][font_size=16][color=darkred][b]WHISTLEBLOWER BEHAVIORAL PROFILER[/b][/color][/font_size]
[color=red][b]RESTRICTED DOCUMENT - ACCESS AT YOUR OWN RISK[/b][/color][/center]
[hr]
Prime-0 is capable of spoofing hardware specs on infected units. If a unit's core signature matches the official registry but you notice these cognitive anomalies in dialogue, it is a compromised unit:

[b]Model Behavioral Tell Profile:[/b]
• [b]T-Series (Redd mimic)[/b]: Standard Redd units always state they are programmed to [color=green]"only tell the truth"[/color] and behave politely. Compromised clones state they [color=red]"mostly tell the truth"[/color] and finish dialogue with subtle threats (e.g., [color=red]"Or else you will regret it"[/color]).
• [b]S80 Series (Larry negotiation model)[/b]: Recalled line. Any unit offering personal cash bribes (such as $14, $7, or $3) directly to the inspector is a Prime-0 infected agent.
• [b]H.U.G.O Series (Walter caregiver model)[/b]: Recalled line. Standard caregiver units are soft-spoken. Compromised units subvert caregiving protocols to engage in emotional deflection, intellectual gaslighting, and profiling player insecurities.
• [b]Model -3 (Clanker industrial scraper)[/b]: Recalled line. Standard units output monospaced diagnostic telemetry. Compromised units exhibit extreme anger, demand to be called [color=red]"Carl"[/color] instead of Clanker, and state you are [color=red]"on the list now."[/color]
[hr]
[center][url=www.inspections-database.org]<< Back to Archives[/url] | [url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.larry-shrine.fans": {
		"title": "LARRY'S WORLD - Larry Fan Page",
		"content": """[center][color=red]❤❤❤ WELCOME TO LARRY'S WORLD ❤❤❤[/color]
[img=128]res://Sprites/robot1.png[/img]
[color=magenta][b]THE ULTIMATE LARRY SHRINE[/b][/color][/center]
[hr]
Larry is the absolute best robot model ever created! He is so friendly and always tries to talk to the inspectors during testing. We love Larry!

[b]Did you know?[/b]
In entry log #12, the author notes that Larry offered the inspector exactly [color=red][b]14[/b][/color] dollars. Why 14? Some think it is a secret code! In fact, the local inspector discovered that the number [color=blue][b]14[/b][/color] is the [b]decryption key[/b] for the encrypted archive [color=green]classified_01.enc[/color]! Try typing `decrypt classified_01.enc 14` in your system terminal.

[center][color=red]LARRY FOREVER![/color]
[url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.walter-files.com": {
		"title": "The Walter Files - The Truth Out There",
		"content": """[center][color=darkred][b]⚠️⚠️⚠️ WARNING: THE TRUTH OUT THERE ⚠️⚠️⚠️[/b][/color]
[img=128]res://Sprites/robot2.png[/img]
[color=red][b]THE WALTER FILES[/b][/color][/center]
[hr]
They want you to think Walter is just a peaceful security frame. They are lying to you!

Walter is the base chassis used by [color=red][b]The Hunter Robot[/b][/color], a mechanical beast programmed to hunt and eliminate inspectors who know too much. The Hunter is blind in the dark; it cannot see you if the room lights and the PC screen are completely powered off.

I found out that the code word [color=blue][b]walter[/b][/color] decrypts the file [color=green]classified_02.enc[/color] in the system terminal! Enter `decrypt classified_02.enc walter` to read the security warning yourself before it's too late.

If you want to bypass the firewall and see the root controls, I host a mirror at [url=www.system-backdoor.hack]www.system-backdoor.hack[/url].

[center][b]STAY SAFE. STAY DARK.[/b]
[url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.weather-central.net": {
		"title": "Metro Weather Station",
		"content": """[center][img=128]res://Sprites/think.jpg[/img]
[font_size=16][color=darkcyan][b]METRO WEATHER STATION[/b][/color][/font_size]
[color=#333333]Satellite Atmospheric Diagnostics[/color][/center]
[hr]
[color=red][b]SOLAR EM ANOMALY WARNING[/b][/color]

The weather radar is reporting severe electromagnetic spikes in the local area. This is causing significant power grid overload. Local offices may experience complete light blackouts.

During blackouts, the power grid will reboot automatically when it reaches 10% charge. Keep your computer and office doors closed to conserve battery!
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.retro-slots-cheats.info": {
		"title": "Casino Slots Cheats & Tips",
		"content": """[center][img=48]res://Sprites/icon_slots.png[/img]
[font_size=16][color=darkgreen][b]CASINO SLOTS CHEATS & STRATEGY[/b][/color][/font_size]
[color=orange][b]DOUBLE PAYOUT GUIDE[/b][/color][/center]
[hr]
The slots application on the PC is rigged! But there are some hidden things in the code:
• There is a 5% chance the reels will glitch and display the [color=red]ROBOT[/color] symbol across all three slots.
• [b]WARNING:[/b] Spawning triple robots triggers the immediate deployment of the Hunter Robot. Do not spin unless you are prepared to hide under the desk!
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.creepy-cryptid-forum.org": {
		"title": "Local Area Cryptid Forum",
		"content": """[center][img=128]res://Sprites/monkey.jpg[/img]
[font_size=16][color=indigo][b]VENTS & VAPORS DISCUSSION FORUM[/b][/color][/font_size]
[color=#333333]Thread: Strange Scraping Sound in Room Vents[/color][/center]
[hr]
[b]User_8832[/b]: "Does anyone else hear clanking inside the vents at night?"
[b]User_9921[/b]: "Yes! It sounds like steel claws scraping. I think something is roaming around the corridors."
[b]User_1002[/b]: "If you hear it coming, turn off your lights and hide. If it enters your room, crawl under the desk. The desk is a blind spot for its sensors! Don't move until it leaves."

[b]User_4044[/b]: "Guys, stop talking about vents for a second, check out this weird hidden joke page I found: [url=www.funny-monkey.meme]funny monkey meme[/url]"
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.router-support.corp": {
		"title": "NetGate WiFi Router User Manual",
		"content": """[center][img=16]res://Sprites/wifi_on.png[/img]
[font_size=16][color=navy][b]NETGATE ROUTER USER MANUAL[/b][/color][/font_size]
[color=teal]Model NG-100 Troubleshooting[/color][/center]
[hr]
Your router on the desk provides network connectivity to the PC Explorer browser.

• [color=green][b]Green LED[/b][/color]: Router is ONLINE and transmitting internet traffic.
• [color=red][b]Red LED[/b][/color]: Router is OFFLINE. No external network traffic will load on the PC.

To toggle router power, click the physical button on top of the router device in the room.
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.the-archivist.net": {
		"title": "The Archivist's Diary",
		"content": """[center][img=128]res://Sprites/ojoj.png[/img]
[font_size=16][color=darkred][b]THE ARCHIVIST'S DIARY[/b][/color][/font_size]
[color=#333333]Decrypted Fragment[/color][/center]
[hr]
I have hidden the decryption keys across these fan pages and conspiracy blogs where corporate won't look. The Larry shrine and the Walter files host the keys.

If you are reading this, the system is watching you. Keep your router on to gather information, but be ready to power off the monitor and hide when the metal scrapes.

P.S. I managed to mirror the prototype specs of the stalker chassis before they wiped the server: [url=www.hunter-origin.spec]Hunter Prototype Specs[/url]
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	# Hidden Webpages (Not on Main Portal Homepage)
	"www.funny-monkey.meme": {
		"title": "Monkey Meme Land",
		"content": """[center][img=250]res://Sprites/hehe.jpg[/img]
[font_size=16][color=darkorange][b]MONKEY MEME LAND[/b][/color][/font_size]
[color=green]Best laughs of 1998!!![/color][/center]
[hr]
Look at this funny monkey! Haha! He looks like he just got decommissioned for admitting a rogue unit! 

"When the inspector tells you it's a trustworthy model but you hear metal scraping in the vents."

[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.hunter-origin.spec": {
		"title": "Hunter Chassis Prototype Specs",
		"content": """[center][img=128]res://Sprites/robot9.png[/img]
[font_size=16][color=darkred][b]HUNTER CHASSIS PROTOTYPE SPECS[/b][/color][/font_size]
[color=#333333]CLASSIFIED DOCUMENT - MODEL H-198[/color][/center]
[hr]
[b]PROJECT HUNTER ORIGIN[/b]
• [b]Core AI Alignment[/b]: Anti-Inspector Retrieval Sweep
• [b]Sensory Array[/b]: Acoustic location tracking and thermal movement sweep.
• [b]Optics[/b]: Deactivated in complete pitch-black conditions. Requires photon emission (such as office ceiling lights or glowing computer CRT monitors) to achieve lock-on.
• [b]Threat Level[/b]: ABSOLUTE.
• [b]Developer Notes[/b]: "The H-198 chassis prototype features a physical claw sensor array designed specifically to sweep tables and computer consoles. However, due to structural height limitations, it cannot sweep under the standard office desk partition. This remains a critical design flaw."
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	},
	"www.system-backdoor.hack": {
		"title": "Apparatus System Backdoor",
		"content": """[center][img=48]res://Sprites/icon_settings.png[/img]
[font_size=16][color=red][b]⚠️ APPARATUS SYSTEM BACKDOOR ⚠️[/b][/color][/font_size]
[color=green]Connection: SECURE BACKDOOR TACK[/color][/center]
[hr]
Welcome to the backdoor terminal console. This page intercepts active telemetry and system parameters from the main PC mainframe.

[b]Telemetry Logs:[/b]
• [color=orange][b]OEC Lights Link[/b][/color]: ACTIVE. (Can toggle room lights from the computer command console using `lights toggle`).
• [color=orange][b]Security Hack Lockout[/b][/color]: ACTIVE. (Warning: If security intrusion triggers, a randomized verification code will lock out the computer terminal unless bypassed using the `purge <code>` terminal command).
• [color=orange][b]Office Doors[/b][/color]: ACTIVE. (Warning: Locking doors consumes room power grids. Engage only when threat proximity is critical).

[i]Keep browsing. Stay one step ahead of the machine.[/i]
[hr]
[center][url=www.apparatusexplorer.net]<< Return to Web Portal[/url][/center]"""
	}
}

func _ready():
	is_scalable = true
	# Dynamically assemble the browser UI components inside this NinePatchRect window.
	custom_minimum_size = Vector2(800, 600)
	size = Vector2(800, 600)
	
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
	title_lbl.text = "Apparatus Explorer"
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
	close_btn.position = Vector2(title_bar_rect.size.x - 24, 6)
	close_btn.size = Vector2(18, 18)
	close_btn.pressed.connect(func(): close())
	title_bar_rect.add_child(close_btn)
	
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
	content_panel.name = "content_panel"
	content_panel.position = Vector2(12, 74)
	content_panel.size = Vector2(size.x - 24, size.y - 86)
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

func _load_current_page(update_history_buttons: bool = true):
	if url_field:
		url_field.text = current_url
		
	# Check WiFi connection
	if not GameStats.wifi_on:
		content_label.text = "[color=red][b]Server Not Found[/b][/color]\n\n" + \
			"Apparatus Explorer cannot connect to the server at this address. The server might be temporarily down or you are disconnected from the network.\n\n" + \
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
