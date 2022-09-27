extends Control

# This script is extremely messy, I know, please use CTRL+F

var LinuxWinePrefix
var LinuxWinePath
var LinuxTerminal = "sh"
#var WorkingDirectory
var f = File.new()
var dir = Directory.new()
var CurrentMenu
var CTheme
var Drive = "Z:"
var PublicIP = ""

# Novetus Config Stuff
var NovetusConfig
var Version = "2009E"
var PlayerName = "Noob"
var UserID = "0"
var RobloxPort = "53640"
var Map = ""
var PlayerLimit = "12"
var UPnP = "False"
var DiscordRichPresence = "False"
var GraphicsMode
var QualityLevel
var ShowServerNotifications = "False"
var ServerBrowserServerName = "Novetus"
var MasterServer = "localhost"
var URI = "?"
var NovetusVersion

var http = HTTPRequest.new()
var NewServerTexture = load("res://textures/charcustom.png")
var NewServerTexturePath
var NewServerIcons = []
var ServerIndex
var Servers 
var Resolutions = [Vector2(700, 600),Vector2(1280,720)]
var serverconfig = ConfigFile.new()
onready var keepupdated = [$Main/HostWindow/ServerDeets,$Background/Info]
var keepupdatedtags = {}
onready var WorkingDirectory = OS.get_executable_path().get_base_dir()

func _ready():
	add_child(http)
	http.connect("request_completed", self, "_http_request_completed")
	OS.min_window_size = Vector2(700, 600)
	OS.max_window_size = Vector2(1920, 1080)
	if !f.file_exists(WorkingDirectory + "/bin/Novetus.exe"):
		WorkingDirectory = OS.get_executable_path().get_base_dir() + "/.."
		print(WorkingDirectory)

	if f.file_exists(WorkingDirectory + "/bin/Novetus.exe"):
		$Main.visible = true
		print("visible")
	else:
		$Main.visible = false
		$Background/FirstTime.visible = false
		$Background/Info.visible = false
	if !f.file_exists(WorkingDirectory + "/bin/Novetus.exe"): return
	match OS.get_name():
		"X11":
			print("yea")
			Drive = "Z:"
			f.open(WorkingDirectory + "/Start.sh", File.WRITE)
			f.store_string('#!/bin/bash\nif [ -z "$4" ]; then WINEPREFIX="$1" "$2" "$3"; else WINEPREFIX="$1" "$2" "$3" "$4"; fi')
			f.close()
			$Background/FirstTime/Panel/TabContainer.current_tab = 0
		"Windows":
			Drive = "C:"
			$Background/FirstTime/Panel/TabContainer.current_tab = 1
			$Main/Settings/ItemList.remove_item(0)
		_:
			$Background/Control2/RichTextLabel.text = "Your operating system is not supported.\nLinux and Windows only."
			$Main.visible = false
	if !dir.dir_exists(WorkingDirectory + "/NovetusFE"): dir.make_dir(WorkingDirectory + "/NovetusFE")
	if !dir.dir_exists(WorkingDirectory + "/NovetusFE/themes"): dir.make_dir(WorkingDirectory + "/NovetusFE/themes")
	loadconfig("/NovetusFE/nfeconfig.ini")
	NovetusConfig = customconfig("/config/config.ini")
	var NovetusInfo = customconfig("/config/info.ini")
	var branch
	var rev
	for i in NovetusInfo:
		if "IsLite=" in i:
			if i.split("=")[1] == "True":
				NovetusVersion = NovetusVersion.replace("%lite%"," Lite")
			else:
				NovetusVersion = NovetusVersion.replace("%lite%","")
		if "Branch=" in i:
			branch = i.replace("Branch=","")
		if "ExtendedVersionRevision=" in i:
			rev = i.replace("ExtendedVersionRevision=","")
			NovetusVersion = NovetusVersion.replace("%extended-revision%",rev)
		if "ExtendedVersionTemplate=" in i:
			if not "//" in i:
				NovetusVersion = i.replace("ExtendedVersionTemplate=","").replace("%version%",branch)
	for i in NovetusConfig:
		if "SelectedClient=" in i:
			Version = i.replace("SelectedClient=","")
		if "MapPath=" in i:
			Map = i.replace("MapPath=","").replace("Z:\\\\","").replace("C:\\\\","").replace("Z://","").replace("C://","").replace("\\\\","//")
		if "PlayerName=" in i:
			PlayerName = i.replace("PlayerName=","")
	for i in list_files_in_directory(WorkingDirectory + "/clients/"):
		$Main/VersionsWindow/Versions/ItemList.add_item(i, load("res://textures/studio.png"))
	$Main/VersionsWindow/Versions/ItemList.sort_items_by_text()
	updateinfo()
	$Main/Serverlist/Versions.text = Version
	if Map != "": $Main/HostWindow/Host.disabled = false
	for i in Resolutions:
		$"Main/Settings/General Settings/Panel/ResolutionList".add_item(str(i).replace("(","").replace(")",""))

func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8()).ip
	PublicIP = response
	print("help")
	updateinfo()
	http.disconnect("request_completed", self, "_http_request_completed")

func updateinfo():
	http.request("https://api.ipify.org/?format=json")
	$Background/Info.text = "Hello, %PLAYER%! Client Selected: %CLIENT%, Map Selected: %MAP%"
	$Main/HostWindow/ServerDeets.text = "Map: %MAP%\nPlayers: %PLAYERS%\nIP: %IP%\nPort: %PORT%\nClient: %CLIENT%\nNovetus Version: %NOVEVER%\nMaster Server: %MASTERSERVER%\nURI: %URI%"
	if PublicIP != "": URI = "novetus://" + to_uri(PublicIP, RobloxPort)
	keepupdatedtags = {"%PLAYER%":PlayerName,"%CLIENT%":Version,"%MAP%":Map.split("//")[-1],"%PORT%":RobloxPort,
	"%PLAYERS%":PlayerLimit,"%MASTERSERVER%":MasterServer,"%URI%":URI,"%IP%":PublicIP,"%NOVEVER%":NovetusVersion}
	for i in keepupdated:
		for v in keepupdatedtags:
			i.text = i.text.replace(v,keepupdatedtags[v])

func customconfig(configfile):
	var config = File.new()
	config.open(WorkingDirectory + configfile, File.READ)
	var content = config.get_as_text()
	content = content.split("\n")
	config.close()
	return content

func loadconfig(arg):
	var config = ConfigFile.new()
	var err = config.load(WorkingDirectory + arg)
	if err != OK:
		return
	match arg:
		"/NovetusFE/nfeconfig.ini":
			LinuxWinePrefix = config.get_value("Linux Settings", "wineprefix")
			LinuxWinePath = config.get_value("Linux Settings", "wine_exec_path")
			OS.window_size = config.get_value("General Settings", "resolution",Vector2(700,600))
			$Background/FirstTime/Panel/TabContainer/Linux/WinePathText.text = LinuxWinePath
			$Background/FirstTime/Panel/TabContainer/Linux/WinePrefixText.text = LinuxWinePrefix
			$Main/Menu.visible = config.get_value("General Settings", "first_time_setup",false)
			NewServerIcons = config.get_value("General Settings", "savedicons")
			for i in $Main/AddServerWindow/ScrollContainer/HBoxContainer.get_children():
				if i is TextureButton:
					i.queue_free()
			for i in NewServerIcons:
				imageadd(i)
			$"Main/Settings/Linux Settings/Panel/WPBox".text = LinuxWinePrefix
			$"Main/Settings/Linux Settings/Panel/WPBox2".text = LinuxWinePath
		"/NovetusFE/servers.ini":
			for i in config.get_sections():
				$Main/Serverlist/ItemList.add_item(i,pathtoimage(config.get_value(i,"icon","res://textures/charcustom.png")))

func main_item_activated(index):
	match $Main/Menu/ItemList.get_item_text(index):
		"Settings":
			menu("Settings")
			$Main/Settings/ItemList.grab_focus()
		"Studio":
			menu("Studio")
			$Main/Studio/ItemList.grab_focus()
		"Multiplayer":
			menu("Multiplayer")
			$Main/Multiplayer/ItemList.grab_focus()
		"Versions":
			$Main/VersionsWindow.popup_centered()
			$Main/VersionsWindow/Versions/ItemList.grab_focus()

func settings_item_activated(index):
	match $Main/Settings/ItemList.get_item_text(index):
		"Back":
			menu("")
			$Main/Menu/ItemList.grab_focus()
		"Linux Settings":
			$"Main/Settings/Linux Settings".visible = true
		"General Settings":
			$"Main/Settings/General Settings".visible = true
		"Launch Novetus":
			launch("/bin/Novetus.exe")
			
			#$Main/Settings/ItemList.grab_focus()
			
func launch(program, args=[]):
	## Important launching function.
	var currentargs
	$OverlayLayer/Overlay.visible = true
	yield(get_tree().create_timer(1),"timeout")
	match OS.get_name():
		"Windows":
			if args.empty():
				#OS.shell_open(WorkingDirectory + program)
				OS.execute(WorkingDirectory + program,[])
			else:
				OS.execute(WorkingDirectory + program,PoolStringArray(args))
		"X11":
			# If your linux wine prefix and wine path are both set to, well, nothing, then
			# Godot will use Shell Open instead of Execute, but if you have set just the prefix then
			# Godot will open normal wine using your specified prefix.
			if LinuxWinePrefix == "":
				if LinuxWinePath !="":
					OS.execute(LinuxWinePath,[WorkingDirectory + program])
				else:
					OS.shell_open(WorkingDirectory + program)
			else:
				currentargs = [WorkingDirectory + "/Start.sh", LinuxWinePrefix, LinuxWinePath, WorkingDirectory + program]
				if args.empty() == false:
					currentargs.append_array(args)
					#for i in args:
					#	currentargs.append(i)
				print(args)
				print(PoolStringArray(currentargs))
				OS.execute("sh",PoolStringArray(currentargs))
	$OverlayLayer/Overlay.visible = false
	
func menu(menu, parent=$Main):
	for i in $Main.get_children():
		if i is Control:
			i.visible = false
	if menu == "": 
		$Main.visible = true
		$Main/Menu.visible = true
		return
	CurrentMenu = menu
	parent.get_node(menu).visible = !parent.get_node(menu).visible


func Back_pressed():
	match CurrentMenu:
		"Settings":
			$"Main/Settings/Linux Settings".visible = false
			$"Main/Settings/General Settings".visible = false


func _on_Save_pressed():
	saveconfig()

func saveconfig():
	var config = ConfigFile.new()
	config.set_value("Linux Settings", "wineprefix", $"Main/Settings/Linux Settings/Panel/WPBox".text)
	config.set_value("Linux Settings", "wine_exec_path", $"Main/Settings/Linux Settings/Panel/WPBox2".text)
	config.set_value("General Settings", "savedicons", NewServerIcons)
	config.set_value("General Settings", "resolution", OS.window_size)
	config.set_value("General Settings", "first_time_setup", $Background/FirstTime/Panel/TabContainer/Linux/NeverShow.pressed)
	config.save(WorkingDirectory + "/NovetusFE/nfeconfig.ini")
	if CTheme != null: get_tree().change_scene_to(CTheme)

func _on_ThemeButton_pressed():
	pass # Replace with function body.

func _on_MenuButton_about_to_show():
	$"Main/Settings/General Settings/Panel/OptionButton".clear()
	$"Main/Settings/General Settings/Panel/OptionButton".add_item("Default")
	for i in list_files_in_directory(WorkingDirectory + "/NovetusFE/themes"):
		$"Main/Settings/General Settings/Panel/OptionButton".add_item(i)
	pass

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files

func _on_OptionButton_item_selected(index):
	CTheme = load(WorkingDirectory + "/NovetusFE/themes/" + $"Main/Settings/General Settings/Panel/OptionButton".get_item_text(index))


func versionslist_activated(index):
	match $Main/VersionsWindow/Versions/ItemList.get_item_text(index):
		"Back":
			menu("")
			$Main/Menu/ItemList.grab_focus()
		_:
			Version = $Main/VersionsWindow/Versions/ItemList.get_item_text(index)
			$Main/VersionsWindow.visible = false
	if $Main/HostWindow/UPNPBox.pressed: UPnP = "True"; else: UPnP = "False"
	if $Main/HostWindow/NotificationsBox.pressed: ShowServerNotifications = "True"; else: ShowServerNotifications = "False"
	savenovetusconfig()
	updateinfo()
	$Main/Serverlist/Versions.text = Version
	

func studio_item_activated(index):
	match $Main/Studio/ItemList.get_item_text(index):
		"Back":
			menu("")
			$Main/Studio/ItemList.grab_focus()
		"Maps":
			$Main/Maps.popup_centered()
		"Launch with map":
			launch("/clients/"+ Version + "/RobloxApp_studio.exe", [Drive + Map])
		"Versions":
			$Main/VersionsWindow.popup_centered()
			
func _input(event):
	if Input.is_action_just_pressed("versions"):
		$Main/VersionsWindow.popup_centered()
	if Input.is_action_just_pressed("map"):
		$Main/Maps.current_dir = WorkingDirectory + "/maps"
		$Main/Maps.popup_centered()
	if Input.is_action_just_pressed("charcus"):
		$Main/CharCus.popup_centered()

func _on_Maps_confirmed(path):
	print($Main/Maps.current_file)
	Map = str($Main/Maps.current_dir.replace(WorkingDirectory,"") + "/" + $Main/Maps.current_file)
	Map = Map.replacen("/","//")
	Map = WorkingDirectory.replacen("/","//") + Map
	updateinfo()
	$Main/HostWindow/Host.disabled = false
	print(Map)


func DirectConnect_Join_pressed():
	var uri = to_uri($Main/DirectConnectWindow/LineEdit.text.split(":")[0].to_ascii().get_string_from_ascii(),$Main/DirectConnectWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii())
	launch("/bin/NovetusURI.exe",["novetus://" + uri])

func to_uri(ip, port):
	var uri = Marshalls.utf8_to_base64(ip) + "|" + Marshalls.utf8_to_base64(port) + "|" + Marshalls.utf8_to_base64(Version)
	uri = Marshalls.utf8_to_base64(uri)
	return uri

func _on_DirectConnect_pressed():
	$Main/DirectConnectWindow.popup_centered()

func multiplayert_item_activated(index):
	match $Main/Multiplayer/ItemList.get_item_text(index):
		"Join":
			#$Main/DirectConnectWindow.popup_centered()
			$Main/Serverlist.popup_centered()
			refreshserverlist()
		"Host":
			#$Main/DirectConnectWindow.popup_centered()
			$Main/HostWindow.popup_centered()
		"Back":
			menu("")
			$Main/Menu/ItemList.grab_focus()

func DirectConnect_Close_pressed():
	$Main/DirectConnectWindow.visible = false


func Firsttime_Button_pressed():
	$Main/Menu.visible = true
	saveconfig()

func _on_AddServer_pressed():
	$Main/AddServerWindow.popup_centered()

func new_icon_pressed():
	$Main/AddServerWindow/ImageSelect.current_dir = WorkingDirectory
	$Main/AddServerWindow/ImageSelect.popup_centered()

func _on_ImageSelect_file_selected(path):
	NewServerIcons.append(path)
	imageadd(path)

func imageadd(path):
	NewServerTexturePath = path
	var t = TextureButton.new()
	t.texture_normal = pathtoimage(path,[56,56])
	$Main/AddServerWindow/ScrollContainer/HBoxContainer.add_child(t)
	NewServerTexture = t.texture_normal
	t.connect("pressed",self,"icon_pressed",[t.texture_normal,t,path])
	var e = t.duplicate()
	$Main/EditServerWindow/ScrollContainer/HBoxContainer.add_child(e)
	e.connect("pressed",self,"icon_pressed",[e.texture_normal,e,path])

func pathtoimage(path,resize=null):
	var img = Image.new()
	var err = img.load(path)
	if(err != 0):
		print("error loading the image")
		return null
	if resize != null:
		img.resize(resize[0],resize[1])
	var img_tex = ImageTexture.new()
	img_tex.create_from_image(img)
	return img_tex

func icon_pressed(icon,node,path):
	for i in $Main/AddServerWindow/ScrollContainer/HBoxContainer.get_children():
		if i is TextureButton:
			i.modulate = Color("707070")
	for i in $Main/EditServerWindow/ScrollContainer/HBoxContainer.get_children():
		if i is TextureButton:
			i.modulate = Color("707070")
	node.modulate = Color("ffffff")
	NewServerTexture = icon
	NewServerTexturePath = path
	print("pressed")

func AddServer_Close_pressed():
	$Main/AddServerWindow.visible = false
	$Main/EditServerWindow.visible = false


func _on_Add_Server_pressed():
	if $Main/AddServerWindow/LineEdit.text == "": return
	saveconfig()
	addtoserverlist($Main/AddServerWindow/LineEdit2.text,NewServerTexture)
	
func refreshserverlist():
	$Main/Serverlist/ItemList.clear()
	loadconfig("/NovetusFE/servers.ini")

func addtoserverlist(servername, icon):
	if f.file_exists(WorkingDirectory + "/NovetusFE/servers.ini"):
		serverconfig.load(WorkingDirectory + "/NovetusFE/servers.ini")
	#var uri = to_uri($Main/AddServerWindow/LineEdit.text.split(":")[0].to_ascii().get_string_from_ascii(),$Main/AddServerWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii())
	var port
	if ":" in $Main/AddServerWindow/LineEdit.text:
		port = $Main/AddServerWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii()
	else:
		port = "53640"
	var ip = $Main/AddServerWindow/LineEdit.text.split(":")[0].to_ascii().get_string_from_ascii()
	#var port = $Main/AddServerWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii()
	#serverconfig.set_value(servername, "uri", "novetus://" + uri)
	serverconfig.set_value(servername, "ip", ip)
	serverconfig.set_value(servername, "port", port)
	serverconfig.set_value(servername, "icon", NewServerTexturePath)
	serverconfig.save(WorkingDirectory + "/NovetusFE/servers.ini")
	refreshserverlist()
	#$Main/Serverlist/ItemList.add_item(servername,icon)
	
	#print($Main/Serverlist/ItemList.items[servername])


func mplist_item_selected(index):
	$Main/Serverlist/Join.disabled = false
	$Main/Serverlist/Edit.disabled = false
	ServerIndex = index


func _on_Join_pressed():
	var e = $Main/Serverlist/ItemList.get_item_text(ServerIndex)
	serverconfig.load(WorkingDirectory + "/NovetusFE/servers.ini")
	launch("/bin/NovetusURI.exe", ["novetus://" + to_uri(serverconfig.get_value(e,"ip"),serverconfig.get_value(e,"port"))])
	

func multi_Versions_pressed():
	$Main/Serverlist/Versions.text = Version
	$Main/VersionsWindow.popup_centered()

func multi_closed():
	$Main/Serverlist.visible = false

func multi_edit_pressed():
	var e = $Main/Serverlist/ItemList.get_item_text(ServerIndex)
	serverconfig.load(WorkingDirectory + "/NovetusFE/servers.ini")
	$Main/EditServerWindow/LineEdit2.text = e
	$Main/EditServerWindow/LineEdit.text = serverconfig.get_value(e,"ip") + ":" + serverconfig.get_value(e,"port")
	$Main/EditServerWindow.popup_centered()

func delete_server_pressed():
	serverconfig.load(WorkingDirectory + "/NovetusFE/servers.ini")
	serverconfig.erase_section($Main/EditServerWindow/LineEdit2.text)
	serverconfig.save(WorkingDirectory + "/NovetusFE/servers.ini")
	$Main/EditServerWindow.visible = false
	refreshserverlist()

func save_server_pressed():
	var e = $Main/Serverlist/ItemList.get_item_text(ServerIndex)
	serverconfig.load(WorkingDirectory + "/NovetusFE/servers.ini")
	serverconfig.erase_section(e)
	e = $Main/EditServerWindow/LineEdit2.text
	serverconfig.set_value(e,"ip",$Main/EditServerWindow/LineEdit.text.split(":")[0])
	serverconfig.set_value(e,"port",$Main/EditServerWindow/LineEdit.text.split(":")[1])
	serverconfig.set_value(e, "icon", NewServerTexturePath)
	serverconfig.save(WorkingDirectory + "/NovetusFE/servers.ini")
	refreshserverlist()
	$Main/EditServerWindow.visible = false


func _on_WinePrefix_pressed():
	$Background/FirstTime/Panel/TabContainer/Linux/WinePrefix/FileDialog.popup_centered()


func wineprefix_dir_selected(dir):
	LinuxWinePrefix = dir
	$Background/FirstTime/Panel/TabContainer/Linux/WinePrefixText.text = LinuxWinePrefix
	$"Main/Settings/Linux Settings/Panel/WPBox".text = LinuxWinePrefix

func _on_WinePrefix2_pressed():
	$Background/FirstTime/Panel/TabContainer/Linux/WinePrefix2/FileDialog.popup_centered()

func wine_exec_file_selected(path):
	LinuxWinePath = path
	$Background/FirstTime/Panel/TabContainer/Linux/WinePathText.text = LinuxWinePath
	$"Main/Settings/Linux Settings/Panel/WPBox2".text = LinuxWinePath


func _on_OpenNovetus_pressed():
	launch("/bin/Novetus.exe")

func _on_ResolutionList_item_selected(index):
	OS.window_size = Vector2($"Main/Settings/General Settings/Panel/ResolutionList".get_item_text(index).replace(" ","").split(",")[0], $"Main/Settings/General Settings/Panel/ResolutionList".get_item_text(index).replace(" ","").split(",")[1])

func _on_Maps_pressed():
	$Main/Maps.popup_centered()
	
func savenovetusconfig():
	var counter = 0
	for i in NovetusConfig:
		var e = i.split("=")
		if e.size() >= 2:
			if "SelectedClient=" in i:
				e[1] = Version
			if "UPnP=" in i:
				e[1] = UPnP
			if "ServerBrowserServerName=" in i:
				e[1] = ServerBrowserServerName
			if "RobloxPort=" in i:
				e[1] = RobloxPort
			if "ServerBrowserServerAddress=" in i:
				e[1] = MasterServer
			if "Map=" in i:
				e[1] = Map.split("//")[-1]
			if "ShowServerNotifications=" in i:
				e[1] = ShowServerNotifications
			if "MapPath=" in i:
				e[1] = Drive + Map.replace("//","\\\\")
			if "MapPathSnip=" in i:
				print(Map.split("//"))
				e[1] = Map.split("//")[-2] + "\\\\" + Map.split("//")[-1]
			e = e[0] + "=" + e[1]
			NovetusConfig[counter] = e
		counter += 1
	print(NovetusConfig)
	f.open(WorkingDirectory + "/config/config.ini", File.WRITE)
	for i in NovetusConfig:
		f.store_line(i)
	f.close()

func _on_Host_pressed():
	if $Main/HostWindow/ServerNameLine.text != "": ServerBrowserServerName = $Main/HostWindow/ServerNameLine.text
	if $Main/HostWindow/ServerPortLine.text != "": RobloxPort = $Main/HostWindow/ServerPortLine.text
	if $Main/HostWindow/PlayerLimitLine.text != "": PlayerLimit = $Main/HostWindow/PlayerLimitLine.text
	if $Main/HostWindow/MasterServerLine.text != "": MasterServer = $Main/HostWindow/MasterServerLine.text
	if $Main/HostWindow/UPNPBox.pressed: UPnP = "True"; else: UPnP = "False"
	if $Main/HostWindow/NotificationsBox.pressed: ShowServerNotifications = "True"; else: ShowServerNotifications = "False"
	savenovetusconfig()
	var args = []
	if $Main/HostWindow/No3DBox.pressed: args.append("-no3d")
	launch("/bin/NovetusCMD", args)
