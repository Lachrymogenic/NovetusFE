extends Node

var Paused = true

var NewServerTexture = load("res://textures/charcustom.png")
var NewServerTexturePath
var NewServerIcons = []
var ServerIndex
var Servers 
var Resolutions = [Vector2(700, 600),Vector2(1280,720)]
var serverconfig = ConfigFile.new()

var WorkshopJSON
var WorkshopRepo = "Lachrymogenic/NovetusFE-WS/"
var WorkshopBranch = "repository"
var WorkshopDefer = "https://github.com/Lachrymogenic/NovetusFE-WS/archive/refs/heads/repository.zip"
var WorkshopUOS = false

var AddonsList = []
var EnabledAddonsList = []
var AddonLua

var LinuxWinePrefix
var LinuxWinePath
var LinuxTerminal = "sh"

# Novetus Config Stuff
var NovetusConfig
var Version = "2009E"
var PlayerName = "Noob"
var UserID = "0"
var RobloxPort = "53640"
var Map = ""
var PlayerLimit = "12"
var UPnP = "False"
var ShowServerNotifications = "False"
var ServerBrowserServerName = "Novetus"
var MasterServer = "localhost"
var URI = "?"

var DownloadedMods = []

var DiscordRichPresence = "False"
var NewGUI = "False" #2011L gui on 2011M
var GraphicsMode = 0 # Automatic, GL Stable, GL Experimental, DirectX
var QualityLevel = 0 # Automatic, Very Low, Low, Medium, High, Ultra, Custom
var ReShade = "False"
var CloseOnLaunch = "False"

var NovetusVersion
var keepupdatedtags = {}
onready var keepupdated = [Global.Main.get_node("Main/HostWindow/ServerDeets"),Global.Main.get_node("Background/Info")]
onready var WorkingDirectory = Global.WorkingDirectory
var f = File.new()

func to_uri(ip, port):
	var uri = Marshalls.utf8_to_base64(ip) + "|" + Marshalls.utf8_to_base64(port) + "|" + Marshalls.utf8_to_base64(Version)
	uri = Marshalls.utf8_to_base64(uri)
	return uri

func customconfig(configfile):
	var config = File.new()
	config.open(WorkingDirectory + configfile, File.READ)
	var content = config.get_as_text()
	content = content.split("\n")
	config.close()
	return content
	
func launch(program, args=[]):
	## Important launching function.
	var currentargs
	$"../Main/OverlayLayer/Overlay".visible = true
	yield(get_tree().create_timer(1),"timeout")
	match OS.get_name():
		"Windows":
			if args.empty():
				#OS.shell_open(Global.WorkingDirectory + program)
				OS.execute(Global.WorkingDirectory + program,[])
			else:
				OS.execute(Global.WorkingDirectory + program,PoolStringArray(args))
		"X11":
			# If your linux wine prefix and wine path are both set to, well, nothing, then
			# Godot will use Shell Open instead of Execute, but if you have set just the prefix then
			# Godot will open normal wine using your specified prefix.
			if LinuxWinePrefix == "":
				if LinuxWinePath !="":
					OS.execute(LinuxWinePath,[Global.WorkingDirectory + program])
				else:
					OS.shell_open(Global.WorkingDirectory + program)
			else:
				currentargs = [Global.WorkingDirectory + "/Start.sh", LinuxWinePrefix, LinuxWinePath, Global.WorkingDirectory + program]
				if args.empty() == false:
					currentargs.append_array(args)
					#for i in args:
					#	currentargs.append(i)
				print(args)
				print(PoolStringArray(currentargs))
				OS.execute("sh",PoolStringArray(currentargs))
	$"../Main/OverlayLayer/Overlay".visible = false
	
func updateinfo():
	$"../Main/Main/Settings/General Settings/Panel/GraphicsModeButton".selected = int(GraphicsMode)
	$"../Main/Main/Settings/General Settings/Panel/GraphicsLevelButton".selected = int(QualityLevel)
	if DiscordRichPresence == "True":
		$"../Main/Main/Settings/General Settings/Panel/DiscordRPCButton".selected = 1
	else:
		$"../Main/Main/Settings/General Settings/Panel/DiscordRPCButton".selected = 0
	if NewGUI == "True":
		$"../Main/Main/Settings/General Settings/Panel/NewGUI".pressed = true
	else:
		$"../Main/Main/Settings/General Settings/Panel/NewGUI".pressed = false
	if ReShade == "True":
		$"../Main/Main/Settings/General Settings/Panel/ReShade".pressed = true
	else:
		$"../Main/Main/Settings/General Settings/Panel/ReShade".pressed = false
	httprequests.http.request("https://api.ipify.org/?format=json")
	$"../Main/Background/Info".text = "Hello, %PLAYER%! Client Selected: %CLIENT%, Map Selected: %MAP%"
	$"../Main/Main/HostWindow/ServerDeets".text = "Map: %MAP%\nPlayers: %PLAYERS%\nIP: %IP%\nPort: %PORT%\nClient: %CLIENT%\nNovetus Version: %NOVEVER%\nMaster Server: %MASTERSERVER%\nURI: %URI%"
	if Global.PublicIP != "": URI = "novetus://" + to_uri(Global.PublicIP, RobloxPort)
	keepupdatedtags = {"%PLAYER%":PlayerName,"%CLIENT%":Version,"%MAP%":Map.split("//")[-1],"%PORT%":RobloxPort,
	"%PLAYERS%":PlayerLimit,"%MASTERSERVER%":MasterServer,"%URI%":URI,"%IP%":Global.PublicIP,"%NOVEVER%":NovetusVersion}
	for i in keepupdated:
		for v in keepupdatedtags:
			i.text = i.text.replace(v,keepupdatedtags[v])

func loadnovetusconfig():
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
		if "GraphicsMode=" in i:
			GraphicsMode = i.replace("GraphicsMode=","")
		if "QualityLevel=" in i:
			QualityLevel = i.replace("QualityLevel=","")
		if "DiscordRichPresence=" in i:
			DiscordRichPresence = i.replace("DiscordRichPresence=","")
		if "NewGUI=" in i:
			NewGUI = i.replace("NewGUI=","")
		if "ReShade=" in i:
			ReShade = i.replace("ReShade=","")

func saveconfig():
	var config = ConfigFile.new()
	config.set_value("Linux Settings", "wineprefix", $"../Main/Main/Settings/Linux Settings/Panel/WPBox".text)
	config.set_value("Linux Settings", "wine_exec_path", $"../Main/Main/Settings/Linux Settings/Panel/WPBox2".text)
	
	config.set_value("General Settings", "savedicons", NewServerIcons)
	config.set_value("General Settings", "theme", ThemeManager.CurrentTheme)
	
	config.set_value("Workshop Settings", "downloaded", DownloadedMods)
	config.set_value("Workshop Settings", "update_on_startup", WorkshopUOS)
	config.set_value("Workshop Settings", "repository", WorkshopRepo)
	config.set_value("Workshop Settings", "branch", WorkshopBranch)
	config.set_value("Workshop Settings", "deferred_zip", WorkshopDefer)
	
	config.set_value("General Settings", "resolution", OS.window_size)
	config.set_value("General Settings", "first_time_setup", $"../Main/Background/FirstTime/Panel/TabContainer/Linux/NeverShow".pressed)
	config.save(Global.WorkingDirectory + "/NovetusFE/nfeconfig.ini")
	
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
	
func addonlist():
	AddonLua = customconfig("/addons/core/AddonLoader.lua")
	for i in AddonLua:
		if "Addons = {" in i:
			for v in i.replace("Addons = {","").replace("}","").split(","):
				for n in v.split('"'): 
					n.replace(" ","")
					if n != "": 
						if n != " ": 
							#print(n)
							EnabledAddonsList.append(n)
				#EnabledAddonsList.append(v)
	
func refreshserverlist():
	$"../Main/Main/Serverlist/ItemList".clear()
	loadconfig("/NovetusFE/servers.ini")
	
func addtoserverlist(servername, icon):
	if f.file_exists(Global.WorkingDirectory + "/NovetusFE/servers.ini"):
		serverconfig.load(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	#var uri = to_uri($Main/AddServerWindow/LineEdit.text.split(":")[0].to_ascii().get_string_from_ascii(),$Main/AddServerWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii())
	var port
	if ":" in $"../Main/Main/AddServerWindow/LineEdit".text:
		port = $"../Main/Main/AddServerWindow/LineEdit".text.split(":")[1].to_ascii().get_string_from_ascii()
	else:
		port = "53640"
	var ip = $"../Main/Main/AddServerWindow/LineEdit".text.split(":")[0].to_ascii().get_string_from_ascii()
	#var port = $Main/AddServerWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii()
	#serverconfig.set_value(servername, "uri", "novetus://" + uri)
	serverconfig.set_value(servername, "ip", ip)
	serverconfig.set_value(servername, "port", port)
	serverconfig.set_value(servername, "icon", NewServerTexturePath)
	serverconfig.save(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	refreshserverlist()
	#$Main/Serverlist/ItemList.add_item(servername,icon)
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
		if "GraphicsMode=" in i:
			GraphicsMode = i.replace("GraphicsMode=","")
		if "QualityLevel=" in i:
			QualityLevel = i.replace("QualityLevel=","")
		if "NewGUI=" in i:
			NewGUI = i.replace("NewGUI=","")
		if "ReShade=" in i:
			ReShade = i.replace("ReShade=","")
			
func savenovetusconfig():
	var counter = 0
	for i in NovetusConfig:
		var e = i.split("=")
		if e.size() >= 2:
			if "SelectedClient=" in i:
				e[1] = Version
			if "ReShade=" in i:
				e[1] = ReShade
			if "QualityLevel=" in i:
				e[1] = QualityLevel
			if "GraphicsMode=" in i:
				e[1] = GraphicsMode
			if "DiscordRichPresence=" in i:
				e[1] = DiscordRichPresence
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
				e[1] = Global.Drive + Map.replace("//","\\\\")
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
	
func saveaddonfile():
	var counter = 0
	var counter2 = 0
	for i in Configs.EnabledAddonsList:
		i = '"' + i + '"'
		Configs.EnabledAddonsList[counter2] = i
		counter2 += 1
	for i in AddonLua:
		if "Addons = {" in i:
			i = "Addons = {%REPLACE%}"
			i = i.replace("%REPLACE%",str(Configs.EnabledAddonsList).replace("[",'').replace("]",''))
			AddonLua[counter] = i
		counter += 1
	f.open(WorkingDirectory + "/addons/core/AddonLoader.lua", File.WRITE)
	for i in AddonLua:
		f.store_line(i)
	f.close()
	counter2 = 0
	for i in Configs.EnabledAddonsList:
		i = i.replace('"',"")
		Configs.EnabledAddonsList[counter2] = i
		counter2 += 1

func imageadd(path):
	NewServerTexturePath = path
	var t = TextureButton.new()
	t.texture_normal = pathtoimage(path,[56,56])
	$"../Main/Main/AddServerWindow/ScrollContainer/HBoxContainer".add_child(t)
	NewServerTexture = t.texture_normal
	t.connect("pressed",$"../Main","icon_pressed",[t.texture_normal,t,path])
	var e = t.duplicate()
	$"../Main/Main/EditServerWindow/ScrollContainer/HBoxContainer".add_child(e)
	e.connect("pressed",$"../Main","icon_pressed",[e.texture_normal,e,path])

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
	
func loadconfig(arg):
	var config = ConfigFile.new()
	var err = config.load(Global.WorkingDirectory + arg)
	if err != OK:
		return
	match arg:
		"/NovetusFE/nfeconfig.ini":
			WorkshopRepo = config.get_value("Workshop Settings", "repository",WorkshopRepo)
			WorkshopBranch = config.get_value("Workshop Settings", "branch",WorkshopBranch)
			WorkshopUOS = config.get_value("Workshop Settings", "update_on_startup",WorkshopUOS)
			WorkshopDefer = config.get_value("Workshop Settings", "deferred_zip",WorkshopDefer)
			
			LinuxWinePrefix = config.get_value("Linux Settings", "wineprefix")
			LinuxWinePath = config.get_value("Linux Settings", "wine_exec_path")
			DownloadedMods = config.get_value("Workshop Settings", "downloaded", [])
			OS.window_size = config.get_value("General Settings", "resolution",Vector2(700,600))
			
			$"../Main/Background/FirstTime/Panel/TabContainer/Linux/WinePathText".text = LinuxWinePath
			$"../Main/Background/FirstTime/Panel/TabContainer/Linux/WinePrefixText".text = LinuxWinePrefix
			$"../Main/Main/Menu".visible = config.get_value("General Settings", "first_time_setup",false)
			$"../Main/Background/FirstTime/Panel/TabContainer/Linux/NeverShow".pressed = config.get_value("General Settings", "first_time_setup",false)
			NewServerIcons = config.get_value("General Settings", "savedicons")
			for i in $"../Main/Main/AddServerWindow/ScrollContainer/HBoxContainer".get_children():
				if i is TextureButton:
					i.queue_free()
			for i in NewServerIcons:
				imageadd(i)
			$"../Main/Main/Settings/Linux Settings/Panel/WPBox".text = LinuxWinePrefix
			$"../Main/Main/Settings/Linux Settings/Panel/WPBox2".text = LinuxWinePath
			$"../Main/Main/Settings/Workshop Settings/Panel/WorkshopRepo".text = WorkshopRepo
			$"../Main/Main/Settings/Workshop Settings/Panel/RepoBranch".text = WorkshopBranch
			$"../Main/Main/Settings/Workshop Settings/Panel/Defer".text = WorkshopDefer
			$"../Main/Main/Settings/Workshop Settings/Panel/WSUpdate".pressed = WorkshopUOS
		"/NovetusFE/servers.ini":
			for i in config.get_sections():
				$"../Main/Main/Serverlist/ItemList".add_item(i,pathtoimage(config.get_value(i,"icon","res://textures/charcustom.png")))
