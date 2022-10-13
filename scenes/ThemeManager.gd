extends Node

var CurrentTheme = ""

var d = Directory.new()
var f = File.new()
var config = ConfigFile.new()

func _ready():
	config.load(Global.WorkingDirectory + "/NovetusFE/nfeconfig.ini")
	CurrentTheme = config.get_value("General Settings", "theme","")
	print(Color("c695a4"))
	loadtheme()
								
func loadtheme():
	#var err = config.load(Global.WorkingDirectory + "/NovetusFE/nfeconfig.ini")
	#if err != OK: return
	if CurrentTheme != "":
		for i in Configs.list_files_in_directory(CurrentTheme):
			print(i)
			match i:
				"index.json":
					var index = parse_json(file_open(CurrentTheme + "/" + i))
					for d in index:
						for v in index[d]:
							#print(index[d][v])
							if "Vector2" in index[d][v]:
								index[d][v] = index[d][v].replace("Vector2(","").replace(")","").replace(" ","").split(",")
								index[d][v] = Vector2(index[d][v][0],index[d][v][1])
							if "image" in index[d][v]:
								index[d][v] = index[d][v].replace("image(","").replace(")","").replace(" ","").split(",")
								index[d][v] = Configs.pathtoimage(CurrentTheme + "/" + index[d][v][0], [int(index[d][v][1]),int(index[d][v][2])])
							Global.Main.get_node(d).set(v,index[d][v])
				"panel.tres":
					find("Panel",i, "panel")
					find("Panel",i, "panel", false, "Main/Settings")
				"darkpanel.tres":
					find("Panel2",i, "panel")
					find("List",i, "panel", false, "Main/WorkshopWindow")
					find(LineEdit,i, "normal", true, "Main/Settings/Linux Settings")
					find(LineEdit,i, "normal", true, "Main/Settings/General Settings")
					find(LineEdit,i, "normal", true, "Main/Settings/Workshop Settings")
				"button-normal.tres":
					find(Button,i, "normal", true)
					find(Button,i, "normal", true, "Main/WorkshopWindow")
					find(Button,i, "normal", true, "Main/Settings/Linux Settings")
					find(Button,i, "normal", true, "Main/Settings/General Settings")
					find(Button,i, "normal", true, "Main/Settings/Workshop Settings")
				"button-disabled.tres":
					find(Button,i, "disabled", true)
					find(Button,i, "disabled", true, "Main/Settings/Linux Settings")
					find(Button,i, "disabled", true, "Main/Settings/General Settings")
					find(Button,i, "disabled", true, "Main/Settings/Workshop Settings")
				"titlebar.tres":
					find2(WindowDialog,i, "panel", true)
				"window-bar-font.tres":
					find2(WindowDialog,i, "title_font", true)
				"itemlist-font.tres":
					find(ItemList,i, "font", true)
				"button-hovered.tres":
					find(Button,i, "hover", true)
					find(Button,i, "hover", true, "Main/Settings/Linux Settings")
					find(Button,i, "hover", true, "Main/Settings/General Settings")
					find(Button,i, "hover", true, "Main/Settings/Workshop Settings")
				"background-gradient.tres":
					var theme = load(CurrentTheme + "/" + i)
					Global.Main.get_node("Background/Gradient").texture = theme
				"clouds.tres":
					var theme = load(CurrentTheme + "/" + i)
					Global.Main.get_node("Background/Clouds").material = theme								

func _input(event):
	if Input.is_action_just_pressed("reload"):
		loadtheme()

func file_open(path):
	var file
	f.open(path, File.READ)
	file = f.get_as_text()
	f.close()
	return file
								
func find(string, i, style, LookForType=false, path="Main"):
	var theme = load(CurrentTheme + "/" + i)
	for d in Global.Main.get_node(path).get_children():
		for v in d.get_children():
			if LookForType == false:
				if v.name == string:
					v.add_stylebox_override(style,theme)
			else:
				if v is string:
					if style == "font":
						v.add_font_override(style,theme)
					else:
						v.add_stylebox_override(style,theme)

func find2(string, i, style, LookForType=false):
	var theme = load(CurrentTheme + "/" + i)
	for d in Global.Main.get_node("Main").get_children():
		if LookForType == false:
			if d.name == string:
				d.add_stylebox_override(style,theme)
		else:
			if d is string:
				if style == "title_font":
					d.add_font_override(style,theme)
				else:
					d.add_stylebox_override(style,theme)

