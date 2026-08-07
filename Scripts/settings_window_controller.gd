extends Control

@onready var display_mode_option = get_node_or_null("GeneralContainer/DisplayModeOption")
@onready var resolution_option = get_node_or_null("GeneralContainer/ResolutionOption")
@onready var fps_option = get_node_or_null("GeneralContainer/FPSOption")
@onready var vsync_checkbox = get_node_or_null("GeneralContainer/VSyncCheckbox")
@onready var crt_checkbox = get_node_or_null("GeneralContainer/CRTCheckbox")
@onready var wallpaper_option = get_node_or_null("GeneralContainer/WallpaperOption")
@onready var brightness_slider = get_node_or_null("GeneralContainer/BrightnessSlider")

const WALLPAPER_KEYS = [
	"teal_solid",
	"teal_grid",
	"bricks",
	"navy_checkers",
	"forest_hatch",
	"purple_diamonds",
	"charcoal_slate"
]

const WALLPAPER_NAMES = [
	"Teal Solid (Win95)",
	"Teal Matrix Grid",
	"Classic Red Bricks",
	"Navy Blue Checkers",
	"Forest Green Weave",
	"Purple Diamonds",
	"Charcoal Slate"
]
var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")

@onready var brightness_value_label = get_node_or_null("GeneralContainer/BrightnessValueLabel")

@onready var volume_slider = get_node_or_null("GeneralContainer/VolumeSlider")
@onready var volume_value_label = get_node_or_null("GeneralContainer/VolumeValueLabel")
@onready var music_volume_slider = get_node_or_null("GeneralContainer/MusicVolumeSlider")
@onready var music_volume_value_label = get_node_or_null("GeneralContainer/MusicVolumeValueLabel")
@onready var sfx_volume_slider = get_node_or_null("GeneralContainer/SfxVolumeSlider") if get_node_or_null("GeneralContainer/SfxVolumeSlider") else get_node_or_null("GeneralContainer/VfxVolumeSlider")
@onready var sfx_volume_value_label = get_node_or_null("GeneralContainer/SfxVolumeValueLabel") if get_node_or_null("GeneralContainer/SfxVolumeValueLabel") else get_node_or_null("GeneralContainer/VfxVolumeValueLabel")
@onready var ambient_volume_slider = get_node_or_null("GeneralContainer/AmbientVolumeSlider")
@onready var ambient_volume_value_label = get_node_or_null("GeneralContainer/AmbientVolumeValueLabel")
@onready var audio_output_option = get_node_or_null("GeneralContainer/AudioOutputOption")

@onready var sensitivity_slider = get_node_or_null("GeneralContainer/SensitivitySlider")
@onready var sensitivity_value_label = get_node_or_null("GeneralContainer/SensitivityValueLabel")
@onready var fov_slider = get_node_or_null("GeneralContainer/FovSlider")
@onready var fov_value_label = get_node_or_null("GeneralContainer/FovValueLabel")
@onready var invert_x_checkbox = get_node_or_null("GeneralContainer/InvertXCheckbox")
@onready var invert_y_checkbox = get_node_or_null("GeneralContainer/InvertYCheckbox")
@onready var quit_button = get_node_or_null("QuitButton")

@onready var general_tab_btn = $GeneralTabBtn
@onready var controls_tab_btn = $ControlsTabBtn
@onready var general_container = $GeneralContainer
@onready var controls_container = $ControlsContainer
@onready var controls_group = $ControlsContainer/ControlsGroup
@onready var controls_label = $ControlsContainer/ControlsGroupLabel

var general_scroll: ScrollContainer = null
var controls_scroll: ScrollContainer = null

func _setup_scroll_containers():
	if general_container and general_container.get_parent() is ScrollContainer:
		general_scroll = general_container.get_parent() as ScrollContainer
	elif general_container:
		general_scroll = ScrollContainer.new()
		general_scroll.name = "GeneralScroll"
		general_scroll.position = Vector2(0, 40)
		general_scroll.size = Vector2(426, 335)
		general_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		general_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		general_scroll.clip_contents = true
		
		var parent_node = general_container.get_parent()
		if parent_node:
			parent_node.remove_child(general_container)
			general_scroll.add_child(general_container)
			parent_node.add_child(general_scroll)
		
		general_container.visible = true
		general_container.position = Vector2(0, 0)
		general_container.custom_minimum_size = Vector2(410, 845)
		general_container.size = Vector2(410, 845)

	if controls_container and controls_container.get_parent() is ScrollContainer:
		controls_scroll = controls_container.get_parent() as ScrollContainer
	elif controls_container:
		controls_scroll = ScrollContainer.new()
		controls_scroll.name = "ControlsScroll"
		controls_scroll.position = Vector2(0, 40)
		controls_scroll.size = Vector2(426, 335)
		controls_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		controls_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		controls_scroll.clip_contents = true
		controls_scroll.visible = false
		
		var parent_node = controls_container.get_parent()
		if parent_node:
			parent_node.remove_child(controls_container)
			controls_scroll.add_child(controls_container)
			parent_node.add_child(controls_scroll)
		
		controls_container.visible = true
		controls_container.position = Vector2(0, 0)
		controls_container.custom_minimum_size = Vector2(410, 690)
		controls_container.size = Vector2(410, 690)

var is_pause_menu: bool = false
var was_visible: bool = false
var opened_frame: int = -1

# Tab layout variables
var current_tab: String = "General"

# Rebinding variables
var listening_action: String = ""
var listening_button: Button = null
var keybind_buttons: Dictionary = {}

const ACTION_LABELS = {
	"move_forward": "Move Forward",
	"move_backward": "Move Backward",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"interact": "Interact",
	"toggle_flashlight": "Flashlight"
}

var available_resolutions: Array[Vector2i] = []
var available_fps_limits: Array[int] = []

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

const FPS_LIMITS = [30, 60, 144, 165, 240, 0]

func _ready():
	# If parent is PauseWindow, dynamically add a CRTOverlay covering the full PauseMenu.
	var pause_window = get_parent()
	if pause_window and pause_window.name == "PauseWindow":
		is_pause_menu = true
		var pause_menu = pause_window.get_parent()
		if pause_menu and pause_menu.name == "PauseMenu":
			pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
			
			var crt = ColorRect.new()
			crt.name = "PauseCRTOverlay"
			crt.mouse_filter = Control.MOUSE_FILTER_IGNORE
			crt.set_anchors_preset(Control.PRESET_FULL_RECT)
			crt.anchor_left = 0
			crt.anchor_top = 0
			crt.anchor_right = 1
			crt.anchor_bottom = 1
			crt.offset_left = 0
			crt.offset_top = 0
			crt.offset_right = 0
			crt.offset_bottom = 0
			
			var crt_shader = preload("res://crt_filter.gdshader")
			var mat = ShaderMaterial.new()
			mat.shader = crt_shader
			mat.set_shader_parameter("scanline_count", 320.0)
			mat.set_shader_parameter("scanline_intensity", 0.08)
			mat.set_shader_parameter("curvature", 0.0)
			mat.set_shader_parameter("vignette_intensity", 0.08)
			mat.set_shader_parameter("grr_intensity", 0.0)
			mat.set_shader_parameter("aberration", 0.0)
			crt.material = mat
			crt.z_index = 20
			
			# Add as a child of PauseMenu so it draws over everything full-screen without squashing
			pause_menu.add_child.call_deferred(crt)
			crt.add_to_group("CRTOverlays")
			crt.visible = GameStats.crt_effect_enabled

	# Dynamic resize and positioning of parent settings window
	var parent = get_parent()
	if parent and parent is Control:
		parent.custom_minimum_size = Vector2(450, 460)
		parent.size = Vector2(450, 460)
		var viewport_size = get_viewport_rect().size
		parent.position.x = (float(viewport_size.x) - 450.0) / 2.0
		parent.position.y = clamp((float(viewport_size.y) - 460.0) / 2.0, 10.0, max(10.0, float(viewport_size.y) - 470.0))
		
		# Update TitleBar
		var title_bar = parent.get_node_or_null("TitleBar")
		if title_bar:
			title_bar.size.x = 438
			title_bar.custom_minimum_size.x = 438
			var close_button = title_bar.get_node_or_null("CloseButton")
			if close_button:
				close_button.position.x = 414

	# Resize self (SettingsBody) to fill parent
	self.size = Vector2(426, 400)
	if "offset_right" in self:
		self.offset_right = 438
	if "offset_bottom" in self:
		self.offset_bottom = 445

	_setup_scroll_containers()

	# Position QuitButton down if it exists
	if quit_button:
		quit_button.position = Vector2(153, 385)
		quit_button.size = Vector2(120, 26)

	# Dynamic creation of Wallpaper option if missing from scene node tree
	if wallpaper_option == null and general_container:
		var wp_lbl = Label.new()
		wp_lbl.name = "WallpaperLabel"
		wp_lbl.text = "Wallpaper Pattern:"
		wp_lbl.position = Vector2(25, 282)
		wp_lbl.size = Vector2(145, 20)
		wp_lbl.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		wp_lbl.add_theme_font_override("font", font_regular)
		wp_lbl.add_theme_font_size_override("font_size", 12)
		general_container.add_child(wp_lbl)
		
		var wp_opt = OptionButton.new()
		wp_opt.name = "WallpaperOption"
		wp_opt.position = Vector2(180, 278)
		wp_opt.size = Vector2(210, 26)
		general_container.add_child(wp_opt)
		wallpaper_option = wp_opt
		style_retro_option_button(wallpaper_option)

	_reposition_general_container_layout()

	# Dynamic creation of FOV slider if missing from scene node tree
	if fov_slider == null and general_container:
		var mouse_group_label = general_container.get_node_or_null("MouseGroupLabel")
		if mouse_group_label:
			mouse_group_label.text = "Mouse & Camera"
		var mouse_group = general_container.get_node_or_null("MouseGroup")
		if mouse_group:
			mouse_group.size.y = 127
			if "offset_bottom" in mouse_group:
				mouse_group.offset_bottom = 720
			
		var label = Label.new()
		label.name = "FovLabel"
		label.text = "Field of View (FOV):"
		label.add_theme_font_override("font", font_regular)
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		label.position = Vector2(25, 655)
		label.size = Vector2(145, 20)
		general_container.add_child(label)

		var val_label = Label.new()
		val_label.name = "FovValueLabel"
		val_label.text = "70°"
		val_label.add_theme_font_override("font", font_regular)
		val_label.add_theme_font_size_override("font_size", 12)
		val_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		val_label.position = Vector2(175, 655)
		val_label.size = Vector2(75, 20)
		general_container.add_child(val_label)
		fov_value_label = val_label

		var slider = HSlider.new()
		slider.name = "FovSlider"
		slider.position = Vector2(25, 676)
		slider.size = Vector2(365, 32)
		slider.min_value = 50.0
		slider.max_value = 110.0
		slider.step = 1.0
		slider.value = 70.0
		var slider_bg = preload("res://RetroWindowsGUI/Windows_Slider_Background.png")
		var slider_handle = preload("res://RetroWindowsGUI/Windows_Slider_Handle.png")
		if slider_bg and slider_handle:
			var sb_tex = StyleBoxTexture.new()
			sb_tex.texture = slider_bg
			sb_tex.texture_margin_left = 2
			sb_tex.texture_margin_top = 1
			sb_tex.texture_margin_right = 2
			sb_tex.texture_margin_bottom = 1
			slider.add_theme_stylebox_override("slider", sb_tex)
			slider.add_theme_icon_override("grabber", slider_handle)
			slider.add_theme_icon_override("grabber_highlight", slider_handle)
		general_container.add_child(slider)
		fov_slider = slider

	# Add binding rows to Controls Group
	var idx = 0
	for action in ACTION_LABELS.keys():
		var row_label = Label.new()
		row_label.text = ACTION_LABELS[action]
		row_label.add_theme_font_override("font", font_regular)
		row_label.add_theme_font_size_override("font_size", 12)
		row_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		row_label.position = Vector2(20, 25 + idx * 38)
		row_label.size = Vector2(160, 25)
		row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		controls_group.add_child(row_label)
		
		var row_btn = Button.new()
		row_btn.add_theme_font_override("font", font_bold)
		row_btn.add_theme_font_size_override("font_size", 12)
		row_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		row_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		row_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		row_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
		row_btn.add_theme_stylebox_override("normal", btn_pressed)
		row_btn.add_theme_stylebox_override("hover", btn_pressed)
		row_btn.add_theme_stylebox_override("pressed", btn_pressed)
		row_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		row_btn.position = Vector2(240, 22 + idx * 38)
		row_btn.size = Vector2(140, 26)
		
		row_btn.pressed.connect(func(): _on_keybind_button_pressed(action, row_btn))
		
		controls_group.add_child(row_btn)
		keybind_buttons[action] = row_btn
		idx += 1

	# Reset Defaults Button inside Controls Group
	var reset_btn = Button.new()
	reset_btn.text = "Reset Defaults"
	reset_btn.add_theme_font_override("font", font_bold)
	reset_btn.add_theme_font_size_override("font_size", 12)
	reset_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_stylebox_override("normal", btn_normal)
	reset_btn.add_theme_stylebox_override("hover", btn_hover)
	reset_btn.add_theme_stylebox_override("pressed", btn_pressed)
	reset_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	reset_btn.position = Vector2(105, 290)
	reset_btn.size = Vector2(196, 28)
	reset_btn.pressed.connect(_on_reset_keybinds_pressed)
	controls_group.add_child(reset_btn)

	# Configure tab buttons pressed callbacks
	general_tab_btn.pressed.connect(func(): _on_tab_changed("General"))
	controls_tab_btn.pressed.connect(func(): _on_tab_changed("Controls"))
	
	_reposition_general_container_layout()

func _fit_group_label(label: Label):
	if label:
		label.custom_minimum_size.x = 0
		label.size.x = label.get_combined_minimum_size().x

func _reposition_general_container_layout():
	if not general_container:
		return
		
	# Display Group
	var display_group = general_container.get_node_or_null("DisplayGroup")
	if display_group:
		display_group.position = Vector2(10, 55)
		display_group.size = Vector2(406, 258)
		
	var display_label = general_container.get_node_or_null("DisplayGroupLabel")
	if display_label:
		display_label.position = Vector2(20, 47)
		_fit_group_label(display_label)
		
	var disp_mode_lbl = general_container.get_node_or_null("DisplayModeLabel")
	if disp_mode_lbl: disp_mode_lbl.position = Vector2(25, 70)
	var disp_mode_opt = general_container.get_node_or_null("DisplayModeOption")
	if disp_mode_opt: disp_mode_opt.position = Vector2(180, 66)
	
	var res_lbl = general_container.get_node_or_null("ResolutionLabel")
	if res_lbl: res_lbl.position = Vector2(25, 103)
	var res_opt = general_container.get_node_or_null("ResolutionOption")
	if res_opt: res_opt.position = Vector2(180, 99)
	
	var fps_lbl = general_container.get_node_or_null("FPSLabel")
	if fps_lbl: fps_lbl.position = Vector2(25, 136)
	var fps_opt = general_container.get_node_or_null("FPSOption")
	if fps_opt: fps_opt.position = Vector2(180, 132)
	
	var vsync_cb = general_container.get_node_or_null("VSyncCheckbox")
	if vsync_cb: vsync_cb.position = Vector2(25, 167)
	
	var crt_cb = general_container.get_node_or_null("CRTCheckbox")
	if crt_cb: crt_cb.position = Vector2(25, 195)
	
	var bright_lbl = general_container.get_node_or_null("BrightnessLabel")
	if bright_lbl: bright_lbl.position = Vector2(25, 224)
	var bright_val = general_container.get_node_or_null("BrightnessValueLabel")
	if bright_val: bright_val.position = Vector2(160, 224)
	var bright_sld = general_container.get_node_or_null("BrightnessSlider")
	if bright_sld: bright_sld.position = Vector2(25, 247)
	
	var wp_lbl = general_container.get_node_or_null("WallpaperLabel")
	if wp_lbl: wp_lbl.position = Vector2(25, 282)
	var wp_opt = general_container.get_node_or_null("WallpaperOption")
	if wp_opt: wp_opt.position = Vector2(180, 278)

	# Audio Group
	var audio_group = general_container.get_node_or_null("AudioGroup")
	if audio_group:
		audio_group.position = Vector2(10, 326)
		audio_group.size = Vector2(406, 312)
		
	var audio_label = general_container.get_node_or_null("AudioGroupLabel")
	if audio_label:
		audio_label.position = Vector2(20, 318)
		_fit_group_label(audio_label)
		
	var audio_out_lbl = general_container.get_node_or_null("AudioOutputLabel")
	if audio_out_lbl: audio_out_lbl.position = Vector2(25, 341)
	var audio_out_opt = general_container.get_node_or_null("AudioOutputOption")
	if audio_out_opt: audio_out_opt.position = Vector2(25, 362)
	
	var vol_lbl = general_container.get_node_or_null("VolumeLabel")
	if vol_lbl: vol_lbl.position = Vector2(25, 398)
	var vol_val = general_container.get_node_or_null("VolumeValueLabel")
	if vol_val: vol_val.position = Vector2(160, 398)
	var vol_sld = general_container.get_node_or_null("VolumeSlider")
	if vol_sld: vol_sld.position = Vector2(25, 421)
	
	var music_lbl = general_container.get_node_or_null("MusicVolumeLabel")
	if music_lbl: music_lbl.position = Vector2(25, 458)
	var music_val = general_container.get_node_or_null("MusicVolumeValueLabel")
	if music_val: music_val.position = Vector2(160, 458)
	var music_sld = general_container.get_node_or_null("MusicVolumeSlider")
	if music_sld: music_sld.position = Vector2(25, 481)
	
	var sfx_lbl = general_container.get_node_or_null("SfxVolumeLabel") if general_container.get_node_or_null("SfxVolumeLabel") else general_container.get_node_or_null("VfxVolumeLabel")
	if sfx_lbl: sfx_lbl.position = Vector2(25, 518)
	var sfx_val = general_container.get_node_or_null("SfxVolumeValueLabel") if general_container.get_node_or_null("SfxVolumeValueLabel") else general_container.get_node_or_null("VfxVolumeValueLabel")
	if sfx_val: sfx_val.position = Vector2(160, 518)
	var sfx_sld = general_container.get_node_or_null("SfxVolumeSlider") if general_container.get_node_or_null("SfxVolumeSlider") else general_container.get_node_or_null("VfxVolumeSlider")
	if sfx_sld: sfx_sld.position = Vector2(25, 541)
	
	var amb_lbl = general_container.get_node_or_null("AmbientVolumeLabel")
	if amb_lbl: amb_lbl.position = Vector2(25, 578)
	var amb_val = general_container.get_node_or_null("AmbientVolumeValueLabel")
	if amb_val: amb_val.position = Vector2(160, 578)
	var amb_sld = general_container.get_node_or_null("AmbientVolumeSlider")
	if amb_sld: amb_sld.position = Vector2(25, 601)

	# Mouse & Camera Group
	var mouse_group = general_container.get_node_or_null("MouseGroup")
	if mouse_group:
		mouse_group.position = Vector2(10, 655)
		mouse_group.size = Vector2(406, 194)
		
	var mouse_label = general_container.get_node_or_null("MouseGroupLabel")
	if mouse_label:
		mouse_label.position = Vector2(20, 647)
		_fit_group_label(mouse_label)
		
	var sens_lbl = general_container.get_node_or_null("SensitivityLabel")
	if sens_lbl: sens_lbl.position = Vector2(25, 670)
	var sens_val = general_container.get_node_or_null("SensitivityValueLabel")
	if sens_val: sens_val.position = Vector2(175, 670)
	var sens_sld = general_container.get_node_or_null("SensitivitySlider")
	if sens_sld: sens_sld.position = Vector2(25, 691)
	
	var fov_lbl = general_container.get_node_or_null("FovLabel")
	if fov_lbl: fov_lbl.position = Vector2(25, 728)
	var fov_val = general_container.get_node_or_null("FovValueLabel")
	if fov_val: fov_val.position = Vector2(175, 728)
	var fov_sld = general_container.get_node_or_null("FovSlider")
	if fov_sld: fov_sld.position = Vector2(25, 749)
	
	var inv_x = general_container.get_node_or_null("InvertXCheckbox")
	if inv_x: inv_x.position = Vector2(25, 783)
	var inv_y = general_container.get_node_or_null("InvertYCheckbox")
	if inv_y: inv_y.position = Vector2(25, 811)

	if controls_label:
		_fit_group_label(controls_label)

	general_container.custom_minimum_size = Vector2(410, 860)
	general_container.size = Vector2(410, 860)

	if not visibility_changed.is_connected(update_ui_from_stats):
		visibility_changed.connect(update_ui_from_stats)
	update_ui_from_stats()
	
	if quit_button:
		quit_button.add_theme_font_override("font", font_bold)
		quit_button.add_theme_font_size_override("font_size", 12)
		quit_button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		quit_button.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		quit_button.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		quit_button.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
		quit_button.add_theme_stylebox_override("normal", btn_normal)
		quit_button.add_theme_stylebox_override("hover", btn_hover)
		quit_button.add_theme_stylebox_override("pressed", btn_pressed)
		quit_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		if not quit_button.pressed.is_connected(_on_quit_pressed):
			quit_button.pressed.connect(_on_quit_pressed)

	if is_pause_menu:
		# Divert TitleBar CloseButton (x) to unpause the tree
		var close_button = get_node_or_null("../TitleBar/CloseButton")
		if close_button:
			for conn in close_button.pressed.get_connections():
				close_button.pressed.disconnect(conn.callable)
			close_button.pressed.connect(_on_resume_pressed)

func _process(_delta):
	if not is_pause_menu:
		return
		
	# Visibility change check to prevent double-triggering input in the same frame
	var pause_menu = get_node_or_null("../..")
	if pause_menu and pause_menu.name == "PauseMenu":
		if pause_menu.visible and not was_visible:
			opened_frame = Engine.get_process_frames()
		was_visible = pause_menu.visible

func _on_resume_pressed():
	if not is_pause_menu:
		return
		
	var pause_menu = get_node_or_null("../..")
	if pause_menu and pause_menu.name == "PauseMenu":
		pause_menu.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_inside_tree():
		return
		
	# Process key rebinding input if listening
	if listening_action != "":
		if event is InputEventKey and event.pressed and not event.echo:
			var new_keycode = event.keycode
			if new_keycode == KEY_ESCAPE:
				listening_action = ""
				listening_button = null
				_update_keybind_buttons()
				get_viewport().set_input_as_handled()
				return
				
			# Swap if already bound to another action
			for act in GameStats.DEFAULT_BINDS.keys():
				if act != listening_action:
					var current_key = GameStats.custom_keybinds.get(act, GameStats.DEFAULT_BINDS[act])
					if current_key == new_keycode:
						var old_key = GameStats.custom_keybinds.get(listening_action, GameStats.DEFAULT_BINDS[listening_action])
						GameStats.custom_keybinds[act] = old_key
						break
						
			GameStats.custom_keybinds[listening_action] = new_keycode
			GameStats.save_settings()
			GameStats.setup_input_map()
			
			listening_action = ""
			listening_button = null
			_update_keybind_buttons()
			get_viewport().set_input_as_handled()
			return

	if not is_pause_menu:
		return
		
	var pause_menu = get_node_or_null("../..")
	if pause_menu and pause_menu.name == "PauseMenu" and pause_menu.visible:
		# Prevent unpausing in the same frame the menu is opened
		if Engine.get_process_frames() == opened_frame:
			return
			
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE)):
			get_viewport().set_input_as_handled()
			_on_resume_pressed()

func update_ui_from_stats():
	listening_action = ""
	listening_button = null
	current_tab = "General"
	_update_tab_visuals()
	_update_keybind_buttons()

	# Apply Windows 98 PopupMenu styling to option buttons
	style_retro_option_button(display_mode_option)
	style_retro_option_button(resolution_option)
	style_retro_option_button(fps_option)

	# Display Mode Option
	if display_mode_option:
		if display_mode_option.item_selected.is_connected(_on_display_mode_selected):
			display_mode_option.item_selected.disconnect(_on_display_mode_selected)
		display_mode_option.clear()
		display_mode_option.add_item("Windowed")
		display_mode_option.add_item("Borderless")
		display_mode_option.add_item("Fullscreen")
		display_mode_option.selected = clamp(GameStats.display_mode, 0, 2)
		display_mode_option.item_selected.connect(_on_display_mode_selected)

	# Resolution Option
	if resolution_option:
		if resolution_option.item_selected.is_connected(_on_resolution_selected):
			resolution_option.item_selected.disconnect(_on_resolution_selected)
		resolution_option.clear()

		available_resolutions.clear()
		for res in RESOLUTIONS:
			available_resolutions.append(res)

		var current_res = Vector2i(GameStats.resolution_width, GameStats.resolution_height)
		if not (current_res in available_resolutions):
			available_resolutions.append(current_res)
			available_resolutions.sort_custom(func(a, b): return (a.x * a.y) < (b.x * b.y))

		var selected_idx = 0
		for i in range(available_resolutions.size()):
			var res = available_resolutions[i]
			resolution_option.add_item("%d x %d" % [res.x, res.y])
			if res == current_res:
				selected_idx = i
		resolution_option.selected = selected_idx
		resolution_option.item_selected.connect(_on_resolution_selected)

	# FPS Option
	if fps_option:
		if fps_option.item_selected.is_connected(_on_fps_selected):
			fps_option.item_selected.disconnect(_on_fps_selected)
		fps_option.clear()

		available_fps_limits.clear()
		for limit in FPS_LIMITS:
			available_fps_limits.append(limit)

		if not (GameStats.fps_limit in available_fps_limits):
			available_fps_limits.append(GameStats.fps_limit)
			var zero_present = 0 in available_fps_limits
			if zero_present:
				available_fps_limits.erase(0)
			available_fps_limits.sort()
			if zero_present:
				available_fps_limits.append(0)

		var selected_fps_idx = available_fps_limits.size() - 1
		for i in range(available_fps_limits.size()):
			var limit = available_fps_limits[i]
			if limit == 0:
				fps_option.add_item("Unlimited")
			else:
				fps_option.add_item("%d FPS" % limit)
			if limit == GameStats.fps_limit:
				selected_fps_idx = i
		fps_option.selected = selected_fps_idx
		fps_option.item_selected.connect(_on_fps_selected)

	# VSync Checkbox
	if vsync_checkbox:
		if vsync_checkbox.toggled.is_connected(_on_vsync_toggled):
			vsync_checkbox.toggled.disconnect(_on_vsync_toggled)
		vsync_checkbox.button_pressed = GameStats.vsync_enabled
		vsync_checkbox.toggled.connect(_on_vsync_toggled)

	# CRT Checkbox
	if crt_checkbox:
		if crt_checkbox.toggled.is_connected(_on_crt_toggled):
			crt_checkbox.toggled.disconnect(_on_crt_toggled)
		crt_checkbox.button_pressed = GameStats.crt_effect_enabled
		crt_checkbox.toggled.connect(_on_crt_toggled)

	# Wallpaper Option
	if wallpaper_option:
		style_retro_option_button(wallpaper_option)
		if wallpaper_option.item_selected.is_connected(_on_wallpaper_selected):
			wallpaper_option.item_selected.disconnect(_on_wallpaper_selected)
		wallpaper_option.clear()
		
		var cur_wp = GameStats.current_wallpaper
		var sel_idx = 0
		for i in range(WALLPAPER_KEYS.size()):
			wallpaper_option.add_item(WALLPAPER_NAMES[i])
			if WALLPAPER_KEYS[i] == cur_wp:
				sel_idx = i
		wallpaper_option.selected = sel_idx
		wallpaper_option.item_selected.connect(_on_wallpaper_selected)

	# Brightness Slider
	if brightness_slider:
		for conn in brightness_slider.value_changed.get_connections():
			brightness_slider.value_changed.disconnect(conn.callable)
		brightness_slider.min_value = 50.0
		brightness_slider.max_value = 150.0
		brightness_slider.step = 1.0
		brightness_slider.value = GameStats.brightness
		brightness_slider.value_changed.connect(_on_brightness_changed)
		if brightness_value_label:
			brightness_value_label.text = str(int(round(GameStats.brightness))) + "%"

	# Main Volume Slider
	_setup_volume_slider(volume_slider, volume_value_label, GameStats.master_volume, func(v): _on_volume_changed("Master", v))
	
	# Music Volume Slider
	_setup_volume_slider(music_volume_slider, music_volume_value_label, GameStats.music_volume, func(v): _on_volume_changed("Music", v))

	# SFX Volume Slider
	_setup_volume_slider(sfx_volume_slider, sfx_volume_value_label, GameStats.sfx_volume, func(v): _on_volume_changed("SFX", v))

	# Ambient Volume Slider
	_setup_volume_slider(ambient_volume_slider, ambient_volume_value_label, GameStats.ambient_volume, func(v): _on_volume_changed("Ambient", v))

	# Audio Output Device Option
	if audio_output_option:
		style_retro_option_button(audio_output_option)
		if audio_output_option.item_selected.is_connected(_on_audio_output_selected):
			audio_output_option.item_selected.disconnect(_on_audio_output_selected)
		audio_output_option.clear()

		var devices = AudioServer.get_output_device_list()
		var selected_idx = 0
		for i in range(devices.size()):
			var dev = devices[i]
			audio_output_option.add_item(dev)
			if dev == GameStats.audio_output_device:
				selected_idx = i

		audio_output_option.selected = selected_idx
		audio_output_option.item_selected.connect(_on_audio_output_selected)

	# Sensitivity Slider
	if sensitivity_slider:
		if sensitivity_slider.value_changed.is_connected(_on_sensitivity_changed):
			sensitivity_slider.value_changed.disconnect(_on_sensitivity_changed)
		var t = (GameStats.mouse_sensitivity - 0.02) / (0.5 - 0.02)
		sensitivity_slider.value = clamp(t * 100.0, 0.0, 100.0)
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_on_sensitivity_changed(sensitivity_slider.value)

	# FOV Slider
	if fov_slider:
		for conn in fov_slider.value_changed.get_connections():
			fov_slider.value_changed.disconnect(conn.callable)
		fov_slider.min_value = 50.0
		fov_slider.max_value = 110.0
		fov_slider.step = 1.0
		fov_slider.value = GameStats.fov
		fov_slider.value_changed.connect(_on_fov_changed)
		if fov_value_label:
			fov_value_label.text = str(int(round(GameStats.fov))) + "°"

	# Invert X Checkbox
	if invert_x_checkbox:
		if invert_x_checkbox.toggled.is_connected(_on_invert_x_toggled):
			invert_x_checkbox.toggled.disconnect(_on_invert_x_toggled)
		invert_x_checkbox.button_pressed = GameStats.invert_mouse_x
		invert_x_checkbox.toggled.connect(_on_invert_x_toggled)

	# Invert Y Checkbox
	if invert_y_checkbox:
		if invert_y_checkbox.toggled.is_connected(_on_invert_y_toggled):
			invert_y_checkbox.toggled.disconnect(_on_invert_y_toggled)
		invert_y_checkbox.button_pressed = GameStats.invert_mouse_y
		invert_y_checkbox.toggled.connect(_on_invert_y_toggled)

	# Disable mouse wheel scrolling on all sliders
	for slider in [brightness_slider, volume_slider, music_volume_slider, sfx_volume_slider, ambient_volume_slider, sensitivity_slider, fov_slider]:
		_disable_slider_scroll(slider)

func _disable_slider_scroll(slider: HSlider):
	if not slider:
		return
	if not slider.gui_input.is_connected(_on_slider_gui_input.bind(slider)):
		slider.gui_input.connect(_on_slider_gui_input.bind(slider))

func _on_slider_gui_input(event: InputEvent, slider: HSlider):
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT]:
			slider.accept_event()
			if mb.pressed:
				var scroll_box = general_scroll if general_scroll else _find_parent_scroll_container(slider)
				if scroll_box:
					var step = 35
					if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						scroll_box.scroll_vertical += step
					elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
						scroll_box.scroll_vertical -= step

func _find_parent_scroll_container(node: Node) -> ScrollContainer:
	var curr = node.get_parent()
	while curr:
		if curr is ScrollContainer:
			return curr as ScrollContainer
		curr = curr.get_parent()
	return null

func _on_invert_x_toggled(toggled_on: bool):
	GameStats.invert_mouse_x = toggled_on
	GameStats.save_settings()

func _on_invert_y_toggled(toggled_on: bool):
	GameStats.invert_mouse_y = toggled_on
	GameStats.save_settings()

func _on_fov_changed(value: float):
	GameStats.fov = value
	if fov_value_label:
		fov_value_label.text = str(int(round(value))) + "°"
	GameStats.apply_fov()
	GameStats.save_settings()

func _setup_volume_slider(slider: HSlider, label: Label, initial_value: float, callback: Callable):
	if slider:
		for conn in slider.value_changed.get_connections():
			slider.value_changed.disconnect(conn.callable)
		slider.value = initial_value
		slider.value_changed.connect(callback)
		if label:
			label.text = str(int(round(initial_value))) + "%"

func _on_display_mode_selected(index: int):
	GameStats.display_mode = index
	GameStats.apply_all_settings()
	GameStats.save_settings()

func _on_resolution_selected(index: int):
	if index >= 0 and index < available_resolutions.size():
		var res = available_resolutions[index]
		GameStats.resolution_width = res.x
		GameStats.resolution_height = res.y
		GameStats.apply_all_settings()
		GameStats.save_settings()

func _on_fps_selected(index: int):
	if index >= 0 and index < available_fps_limits.size():
		GameStats.fps_limit = available_fps_limits[index]
		GameStats.apply_all_settings()
		GameStats.save_settings()

func _on_vsync_toggled(toggled_on: bool):
	GameStats.vsync_enabled = toggled_on
	GameStats.apply_all_settings()
	GameStats.save_settings()

func _on_wallpaper_selected(index: int):
	if index >= 0 and index < WALLPAPER_KEYS.size():
		var wp_key = WALLPAPER_KEYS[index]
		GameStats.current_wallpaper = wp_key
		GameStats.wallpaper_changed.emit(wp_key)
		GameStats.save_settings()

func _on_crt_toggled(toggled_on: bool):
	GameStats.crt_effect_enabled = toggled_on
	GameStats.save_settings()
	GameStats.update_crt_overlays()

func _on_brightness_changed(value: float):
	GameStats.brightness = value
	if brightness_value_label:
		brightness_value_label.text = str(int(round(value))) + "%"
	GameStats.apply_brightness()
	GameStats.save_settings()

func _on_volume_changed(bus_name: String, value: float):
	if bus_name == "Master":
		GameStats.master_volume = value
		if volume_value_label:
			volume_value_label.text = str(int(round(value))) + "%"
	elif bus_name == "Music":
		GameStats.music_volume = value
		if music_volume_value_label:
			music_volume_value_label.text = str(int(round(value))) + "%"
	elif bus_name == "SFX":
		GameStats.sfx_volume = value
		if sfx_volume_value_label:
			sfx_volume_value_label.text = str(int(round(value))) + "%"
	elif bus_name == "Ambient":
		GameStats.ambient_volume = value
		if ambient_volume_value_label:
			ambient_volume_value_label.text = str(int(round(value))) + "%"
			
	GameStats.apply_bus_volume(bus_name, value)
	GameStats.save_settings()

func _on_audio_output_selected(index: int):
	if audio_output_option:
		var device_name = audio_output_option.get_item_text(index)
		GameStats.audio_output_device = device_name
		AudioServer.output_device = device_name
		GameStats.save_settings()

func _on_sensitivity_changed(value: float):
	var sens = 0.02 + (value / 100.0) * (0.5 - 0.02)
	GameStats.mouse_sensitivity = sens
	GameStats.save_settings()
	if sensitivity_value_label:
		sensitivity_value_label.text = "%.2f" % sens

func _on_quit_pressed():
	var parent = get_parent()
	if not parent:
		GameStats.quit_or_menu(get_tree())
		return
		
	var parent_size = parent.size if parent.size != Vector2.ZERO else Vector2(450, 460)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.4)
	overlay.size = parent_size
	overlay.position = Vector2.ZERO
	parent.add_child(overlay)
	
	var dialog = NinePatchRect.new()
	dialog.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	dialog.patch_margin_left = 12
	dialog.patch_margin_top = 12
	dialog.patch_margin_right = 12
	dialog.patch_margin_bottom = 12
	dialog.size = Vector2(280, 140)
	dialog.position = (parent_size - dialog.size) / 2.0
	overlay.add_child(dialog)
	
	var title_bar = NinePatchRect.new()
	title_bar.texture = preload("res://RetroWindowsGUI/Window_Header.png")
	title_bar.region_rect = Rect2(0, 0, 48, 25)
	title_bar.patch_margin_left = 5
	title_bar.patch_margin_top = 3
	title_bar.patch_margin_right = 5
	title_bar.patch_margin_bottom = 3
	title_bar.position = Vector2(6, 6)
	title_bar.size = Vector2(dialog.size.x - 12, 30)
	dialog.add_child(title_bar)
	
	var title_label = Label.new()
	title_label.text = "Exit Game"
	title_label.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.position = Vector2(8, 6)
	title_bar.add_child(title_label)
	
	var msg_label = Label.new()
	msg_label.text = "Do you want to quit game?"
	msg_label.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_label.position = Vector2(10, 45)
	msg_label.size = Vector2(dialog.size.x - 20, 30)
	dialog.add_child(msg_label)
	
	var yes_btn = Button.new()
	yes_btn.text = "Yes"
	yes_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
	yes_btn.add_theme_font_size_override("font_size", 12)
	yes_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_stylebox_override("normal", preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres"))
	yes_btn.add_theme_stylebox_override("hover", preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres"))
	yes_btn.add_theme_stylebox_override("pressed", preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres"))
	yes_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	yes_btn.position = Vector2(45, 90)
	yes_btn.size = Vector2(85, 30)
	yes_btn.pressed.connect(func():
		GameStats.quit_or_menu(get_tree())
	)
	dialog.add_child(yes_btn)
	
	var no_btn = Button.new()
	no_btn.text = "No"
	no_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
	no_btn.add_theme_font_size_override("font_size", 12)
	no_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	no_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	no_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	no_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	no_btn.add_theme_stylebox_override("normal", preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres"))
	no_btn.add_theme_stylebox_override("hover", preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres"))
	no_btn.add_theme_stylebox_override("pressed", preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres"))
	no_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	no_btn.position = Vector2(150, 90)
	no_btn.size = Vector2(85, 30)
	no_btn.pressed.connect(func():
		overlay.queue_free()
	)
	dialog.add_child(no_btn)

func _on_tab_changed(tab_name: String):
	current_tab = tab_name
	_update_tab_visuals()

func _update_tab_visuals():
	# Using class-level preloaded fonts and styleboxes

	if current_tab == "General":
		general_tab_btn.add_theme_stylebox_override("normal", btn_hover)
		general_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		general_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		general_tab_btn.add_theme_font_override("font", font_bold)
		general_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		controls_tab_btn.add_theme_stylebox_override("normal", btn_normal)
		controls_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		controls_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		controls_tab_btn.add_theme_font_override("font", font_regular)
		controls_tab_btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
		controls_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		controls_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		if general_scroll:
			general_scroll.visible = true
		if general_container:
			general_container.visible = true
			
		if controls_scroll:
			controls_scroll.visible = false
		if controls_container:
			controls_container.visible = false
	else:
		general_tab_btn.add_theme_stylebox_override("normal", btn_normal)
		general_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		general_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		general_tab_btn.add_theme_font_override("font", font_regular)
		general_tab_btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
		general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		controls_tab_btn.add_theme_stylebox_override("normal", btn_hover)
		controls_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		controls_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		controls_tab_btn.add_theme_font_override("font", font_bold)
		controls_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		controls_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		controls_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		if general_scroll:
			general_scroll.visible = false
		if general_container:
			general_container.visible = false
			
		if controls_scroll:
			controls_scroll.visible = true
		if controls_container:
			controls_container.visible = true
		
		listening_action = ""
		listening_button = null
		_update_keybind_buttons()

func _update_keybind_buttons():
	for action in keybind_buttons.keys():
		var btn = keybind_buttons[action]
		if listening_action == action:
			btn.text = "[ Press Key ]"
		else:
			var keycode = GameStats.custom_keybinds.get(action, GameStats.DEFAULT_BINDS[action])
			var key_name = OS.get_keycode_string(keycode)
			btn.text = key_name

func _on_keybind_button_pressed(action: String, btn: Button):
	if listening_action == action:
		return
		
	if listening_action != "":
		listening_action = ""
		_update_keybind_buttons()
		
	listening_action = action
	listening_button = btn
	btn.text = "[ Press Key ]"
	btn.release_focus()

func _on_reset_keybinds_pressed():
	GameStats.custom_keybinds.clear()
	GameStats.save_settings()
	GameStats.setup_input_map()
	listening_action = ""
	listening_button = null
	_update_keybind_buttons()

func style_retro_option_button(btn: OptionButton):
	if not btn:
		return
	
	# Using class-level preloaded fonts and styleboxes

	btn.add_theme_font_override("font", font_bold)
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	btn.add_theme_stylebox_override("normal", btn_pressed)
	btn.add_theme_stylebox_override("hover", btn_pressed)
	btn.add_theme_stylebox_override("pressed", btn_pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	var popup = btn.get_popup()
	if popup:
		popup.add_theme_font_override("font", font_regular)
		popup.add_theme_font_size_override("font_size", 12)
		popup.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		popup.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
		popup.add_theme_color_override("font_accelerator_color", Color(0.3, 0.3, 0.3, 1))
		popup.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5, 1))
		popup.add_theme_color_override("font_separator_color", Color(0, 0, 0, 1))
		
		# Windows 98 3D Panel border stylebox for dropdown popup
		var panel_sb = StyleBoxFlat.new()
		panel_sb.bg_color = Color(0.83137, 0.81568, 0.78431, 1.0) # #D4D0C8
		panel_sb.border_width_left = 2
		panel_sb.border_width_top = 2
		panel_sb.border_width_right = 2
		panel_sb.border_width_bottom = 2
		panel_sb.border_color = Color(0.3, 0.3, 0.3, 1.0)
		panel_sb.corner_radius_top_left = 0
		panel_sb.corner_radius_top_right = 0
		panel_sb.corner_radius_bottom_left = 0
		panel_sb.corner_radius_bottom_right = 0
		panel_sb.content_margin_left = 2
		panel_sb.content_margin_top = 2
		panel_sb.content_margin_right = 2
		panel_sb.content_margin_bottom = 2
		popup.add_theme_stylebox_override("panel", panel_sb)

		# Windows 98 selection highlight: Navy Blue (#000080) bar
		var hover_sb = StyleBoxFlat.new()
		hover_sb.bg_color = Color(0.0, 0.0, 0.502, 1.0) # Windows classic selection blue
		hover_sb.corner_radius_top_left = 0
		hover_sb.corner_radius_top_right = 0
		hover_sb.corner_radius_bottom_left = 0
		hover_sb.corner_radius_bottom_right = 0
		hover_sb.content_margin_left = 4
		hover_sb.content_margin_top = 2
		hover_sb.content_margin_right = 4
		hover_sb.content_margin_bottom = 2
		popup.add_theme_stylebox_override("hover", hover_sb)
		
		# Replace radio/check icons with empty texture for clean retro text dropdown
		var empty_img = Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
		var empty_icon = ImageTexture.create_from_image(empty_img)
		popup.add_theme_icon_override("radio_checked", empty_icon)
		popup.add_theme_icon_override("radio_unchecked", empty_icon)
		popup.add_theme_icon_override("checked", empty_icon)
		popup.add_theme_icon_override("unchecked", empty_icon)
