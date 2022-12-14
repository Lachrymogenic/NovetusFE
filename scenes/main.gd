extends Control

var f = File.new()
var dir = Directory.new()
var CurrentMenu


func _ready():
	#httprequests.get_store()
	#httprequests.uncompress(Global.WorkingDirectory + "/NovetusFE/workshop/downloads/main.zip","Red-sGunMeshes-main/shareddata/Guns/Fonts/AWP.mesh")
	$Main/WorkshopWindow/List.visible = false
	OS.min_window_size = Vector2(700, 600)
	OS.max_window_size = Vector2(1920, 1080)
	get_tree().get_root().connect("size_changed", self, "sizechange")
	Configs.loadconfig("/NovetusFE/nfeconfig.ini")
	Configs.addonlist()
	Configs.loadnovetusconfig()
	if Configs.WorkshopUOS == true:
		httprequests.get_store()
	for i in Configs.list_files_in_directory(Global.WorkingDirectory + "/clients/"):
		$Main/VersionsWindow/Versions/ItemList.add_item(i, load("res://textures/studio.png"))
	$Main/VersionsWindow/Versions/ItemList.sort_items_by_text()
	Configs.updateinfo()
	$Main/Serverlist/Versions.text = Configs.Version
	$Main/HostWindow/Versions.text = Configs.Version
	if Configs.Map != "": $Main/HostWindow/Host.disabled = false
	for i in Configs.Resolutions:
		$"Main/Settings/General Settings/Panel/ResolutionList".add_item(str(i).replace("(","").replace(")",""))
	$"Main/Settings/General Settings/Panel/OptionButton".clear()
	$"Main/Settings/General Settings/Panel/OptionButton".add_item("Default")
	for i in Configs.list_files_in_directory(Global.WorkingDirectory + "/NovetusFE/themes"):
		if not "." in i:
			$"Main/Settings/General Settings/Panel/OptionButton".add_item(i)
	pass


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
		"Workshop":
			$Main/WorkshopWindow.popup_centered()
			if Configs.WorkshopUOS == false:
					for i in Global.Main.get_node("Main/WorkshopWindow/List/ScrollContainer/GridContainer").get_children():
						i.queue_free()
					httprequests.get_store()
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
		"Workshop Settings":
			$"Main/Settings/Workshop Settings".visible = true
		"General Settings":
			$"Main/Settings/General Settings".visible = true
		"Launch Novetus":
			Configs.launch("/bin/Novetus.exe")
			
			#$Main/Settings/ItemList.grab_focus()
			
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
			$"Main/Settings/Workshop Settings".visible = false

func _on_Save_pressed():
	Configs.GraphicsMode = str($"Main/Settings/General Settings/Panel/GraphicsModeButton".selected)
	Configs.QualityLevel = str($"Main/Settings/General Settings/Panel/GraphicsLevelButton".selected)
	Configs.WorkshopUOS = $"Main/Settings/Workshop Settings/Panel/WSUpdate".pressed
	Configs.WorkshopRepo = $"Main/Settings/Workshop Settings/Panel/WorkshopRepo".text
	Configs.WorkshopBranch = $"Main/Settings/Workshop Settings/Panel/RepoBranch".text
	Configs.WorkshopDefer = $"Main/Settings/Workshop Settings/Panel/Defer".text
	if $"Main/Settings/General Settings/Panel/DiscordRPCButton".selected == 1: 
		Configs.DiscordRichPresence = "True"
	else:
		Configs.DiscordRichPresence = "False"
	if $"Main/Settings/General Settings/Panel/NewGUI".pressed:
		Configs.NewGUI = "True"
	else:
		Configs.NewGUI = "False"
	if $"Main/Settings/General Settings/Panel/ReShade".pressed:
		Configs.ReShade = "True"
	else:
		Configs.ReShade = "False"
	Configs.saveconfig()
	Configs.savenovetusconfig()

func _on_ThemeButton_pressed():
	pass # Replace with function body.

func _on_OptionButton_item_selected(index):
	ThemeManager.CurrentTheme = Global.WorkingDirectory + "/NovetusFE/themes/" + $"Main/Settings/General Settings/Panel/OptionButton".get_item_text(index)
	if $"Main/Settings/General Settings/Panel/OptionButton".get_item_text(index) == "Default":
		ThemeManager.CurrentTheme = "res://scenes/style"
	print(ThemeManager.CurrentTheme)
	ThemeManager.loadtheme()

func versionslist_activated(index):
	match $Main/VersionsWindow/Versions/ItemList.get_item_text(index):
		"Back":
			menu("")
			$Main/Menu/ItemList.grab_focus()
		_:
			Configs.Version = $Main/VersionsWindow/Versions/ItemList.get_item_text(index)
			$Main/VersionsWindow.visible = false
	if $Main/HostWindow/UPNPBox.pressed: Configs.UPnP = "True"; else: Configs.UPnP = "False"
	if $Main/HostWindow/NotificationsBox.pressed: Configs.ShowServerNotifications = "True"; else: Configs.ShowServerNotifications = "False"
	Configs.savenovetusconfig()
	Configs.updateinfo()
	$Main/Serverlist/Versions.text = Configs.Version
	
func studio_item_activated(index):
	match $Main/Studio/ItemList.get_item_text(index):
		"Back":
			menu("")
			$Main/Studio/ItemList.grab_focus()
		"Maps":
			$Main/Maps.popup_centered()
		"Launch with map":
			Configs.launch("/clients/"+ Configs.Version + "/RobloxApp_studio.exe", [Global.Drive + Configs.Map])
		"Versions":
			$Main/VersionsWindow.popup_centered()
			
func _input(event):
	if Input.is_action_just_pressed("versions"):
		$Main/VersionsWindow.popup_centered()
	if Input.is_action_just_pressed("map"):
		$Main/Maps.current_dir = Global.WorkingDirectory + "/maps"
		$Main/Maps.popup_centered()
	if Input.is_action_just_pressed("charcus"):
		$Main/CharCus.popup_centered()

func _on_Maps_confirmed(path):
	print($Main/Maps.current_file)
	Configs.Map = str($Main/Maps.current_dir.replace(Global.WorkingDirectory,"") + "/" + $Main/Maps.current_file)
	Configs.Map = Configs.Map.replacen("/","//")
	Configs.Map = Global.WorkingDirectory.replacen("/","//") + Configs.Map
	Configs.updateinfo()
	$Main/HostWindow/Host.disabled = false
	print(Configs.Map)

func DirectConnect_Join_pressed():
	var uri = Configs.to_uri($Main/DirectConnectWindow/LineEdit.text.split(":")[0].to_ascii().get_string_from_ascii(),$Main/DirectConnectWindow/LineEdit.text.split(":")[1].to_ascii().get_string_from_ascii())
	Configs.launch("/bin/NovetusURI.exe",["novetus://" + uri])

func _on_DirectConnect_pressed():
	$Main/DirectConnectWindow.popup_centered()

func multiplayert_item_activated(index):
	match $Main/Multiplayer/ItemList.get_item_text(index):
		"Join":
			#$Main/DirectConnectWindow.popup_centered()
			$Main/Serverlist.popup_centered()
			Configs.refreshserverlist()
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
	Configs.saveconfig()

func _on_AddServer_pressed():
	$Main/AddServerWindow.popup_centered()

func new_icon_pressed():
	$Main/AddServerWindow/ImageSelect.current_dir = Global.WorkingDirectory
	$Main/AddServerWindow/ImageSelect.popup_centered()

func _on_ImageSelect_file_selected(path):
	Configs.NewServerIcons.append(path)
	Configs.imageadd(path)

func icon_pressed(icon,node,path):
	for i in $Main/AddServerWindow/ScrollContainer/HBoxContainer.get_children():
		if i is TextureButton:
			i.modulate = Color("707070")
	for i in $Main/EditServerWindow/ScrollContainer/HBoxContainer.get_children():
		if i is TextureButton:
			i.modulate = Color("707070")
	node.modulate = Color("ffffff")
	Configs.NewServerTexture = icon
	Configs.NewServerTexturePath = path
	print("pressed")

func AddServer_Close_pressed():
	$Main/AddServerWindow.visible = false
	$Main/EditServerWindow.visible = false

func _on_Add_Server_pressed():
	if $Main/AddServerWindow/LineEdit.text == "": return
	Configs.saveconfig()
	Configs.addtoserverlist($Main/AddServerWindow/LineEdit2.text,Configs.NewServerTexture)

func mplist_item_selected(index):
	$Main/Serverlist/Join.disabled = false
	$Main/Serverlist/Edit.disabled = false
	Configs.ServerIndex = index

func _on_Join_pressed():
	var e = $Main/Serverlist/ItemList.get_item_text(Configs.ServerIndex)
	Configs.serverconfig.load(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	Configs.launch("/bin/NovetusURI.exe", ["novetus://" + Configs.to_uri(Configs.serverconfig.get_value(e,"ip"),Configs.serverconfig.get_value(e,"port"))])
	
func multi_Versions_pressed():
	$Main/Serverlist/Versions.text = Configs.Version
	$Main/HostWindow/Versions.text = Configs.Version
	$Main/VersionsWindow.popup_centered()

func multi_closed():
	$Main/Serverlist.visible = false

func multi_edit_pressed():
	var e = $Main/Serverlist/ItemList.get_item_text(Configs.ServerIndex)
	Configs.serverconfig.load(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	$Main/EditServerWindow/LineEdit2.text = e
	$Main/EditServerWindow/LineEdit.text = Configs.serverconfig.get_value(e,"ip") + ":" + Configs.serverconfig.get_value(e,"port")
	$Main/EditServerWindow.popup_centered()

func delete_server_pressed():
	Configs.serverconfig.load(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	Configs.serverconfig.erase_section($Main/EditServerWindow/LineEdit2.text)
	Configs.serverconfig.save(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	$Main/EditServerWindow.visible = false
	Configs.refreshserverlist()

func save_server_pressed():
	var e = $Main/Serverlist/ItemList.get_item_text(Configs.ServerIndex)
	Configs.serverconfig.load(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	Configs.serverconfig.erase_section(e)
	e = $Main/EditServerWindow/LineEdit2.text
	Configs.serverconfig.set_value(e,"ip",$Main/EditServerWindow/LineEdit.text.split(":")[0])
	Configs.serverconfig.set_value(e,"port",$Main/EditServerWindow/LineEdit.text.split(":")[1])
	Configs.serverconfig.set_value(e, "icon", Configs.NewServerTexturePath)
	Configs.serverconfig.save(Global.WorkingDirectory + "/NovetusFE/servers.ini")
	Configs.refreshserverlist()
	$Main/EditServerWindow.visible = false

func _on_WinePrefix_pressed():
	$Background/FirstTime/Panel/TabContainer/Linux/WinePrefix/FileDialog.popup_centered()

func wineprefix_dir_selected(dir):
	Configs.LinuxWinePrefix = dir
	$Background/FirstTime/Panel/TabContainer/Linux/WinePrefixText.text = Configs.LinuxWinePrefix
	$"Main/Settings/Linux Settings/Panel/WPBox".text = Configs.LinuxWinePrefix

func _on_WinePrefix2_pressed():
	$Background/FirstTime/Panel/TabContainer/Linux/WinePrefix2/FileDialog.popup_centered()

func wine_exec_file_selected(path):
	Configs.LinuxWinePath = path
	$Background/FirstTime/Panel/TabContainer/Linux/WinePathText.text = Configs.LinuxWinePath
	$"Main/Settings/Linux Settings/Panel/WPBox2".text = Configs.LinuxWinePath

func _on_OpenNovetus_pressed():
	Configs.launch("/bin/Novetus.exe")

func _on_ResolutionList_item_selected(index):
	OS.window_size = Vector2($"Main/Settings/General Settings/Panel/ResolutionList".get_item_text(index).replace(" ","").split(",")[0], $"Main/Settings/General Settings/Panel/ResolutionList".get_item_text(index).replace(" ","").split(",")[1])

func sizechange():
	if get_viewport_rect().size > Vector2(1100, 600):
		$Controls.visible = true
	else:
		$Controls.visible = false

func _on_Maps_pressed():
	$Main/Maps.popup_centered()

func _on_Host_pressed():
	if $Main/HostWindow/ServerNameLine.text != "": Configs.ServerBrowserServerName = $Main/HostWindow/ServerNameLine.text
	if $Main/HostWindow/ServerPortLine.text != "": Configs.RobloxPort = $Main/HostWindow/ServerPortLine.text
	if $Main/HostWindow/PlayerLimitLine.text != "": Configs.PlayerLimit = $Main/HostWindow/PlayerLimitLine.text
	if $Main/HostWindow/MasterServerLine.text != "": Configs.MasterServer = $Main/HostWindow/MasterServerLine.text
	if $Main/HostWindow/UPNPBox.pressed: Configs.UPnP = "True"; else: Configs.UPnP = "False"
	if $Main/HostWindow/NotificationsBox.pressed: Configs.ShowServerNotifications = "True"; else: Configs.ShowServerNotifications = "False"
	Configs.savenovetusconfig()
	var args = []
	if $Main/HostWindow/No3DBox.pressed: args.append("-no3d")
	Configs.launch("/bin/NovetusCMD", args)

func bitlslink():
	OS.shell_open("https://bitl.itch.io/novetus")

func hostwindow_close_pressed():
	$Main/HostWindow.visible = false


func AddonsList_Close_pressed():
	$Main/AddonsWindow.visible = false
	Configs.saveaddonfile()

func _on_Addons_pressed():
	$Main/AddonsWindow/Disabled.clear()
	$Main/AddonsWindow/Enabled.clear()
	for i in Configs.list_files_in_directory(Configs.WorkingDirectory + "/addons/"):
		if i.ends_with(".lua"):
			if not i.replace(".lua","") in Configs.EnabledAddonsList:
				Configs.AddonsList.append(i.replace(".lua",""))
				$Main/AddonsWindow/Disabled.add_item(i.replace(".lua",""), load("res://textures/settings.png"))
	for i in Configs.EnabledAddonsList:
		$Main/AddonsWindow/Enabled.add_item(i, load("res://textures/settings.png"))
	$Main/AddonsWindow.popup_centered()


func _on_DisabledAddon_item_activated(index):
	Configs.EnabledAddonsList.append($Main/AddonsWindow/Disabled.get_item_text(index))
	$Main/AddonsWindow/Enabled.add_item($Main/AddonsWindow/Disabled.get_item_text(index),load("res://textures/settings.png"))
	$Main/AddonsWindow/Disabled.remove_item(index)


func _on_Enabled_Addon_activated(index):
	if $Main/AddonsWindow/Enabled.get_item_text(index) in Configs.EnabledAddonsList:
		Configs.EnabledAddonsList.erase($Main/AddonsWindow/Enabled.get_item_text(index))
	$Main/AddonsWindow/Disabled.add_item($Main/AddonsWindow/Enabled.get_item_text(index),load("res://textures/settings.png"))
	$Main/AddonsWindow/Enabled.remove_item(index)


func Workshop_Search_text_changed(new_text):
	if new_text != "":
		if len(new_text.split(" ")) >= 1: new_text = new_text.split(" ")[-1]
		for i in $Main/WorkshopWindow/List/ScrollContainer/GridContainer.get_children():
			if not new_text.to_lower() in i.get_node("Name").text.to_lower():
				i.visible = false
			else:
				i.visible = true
			if i.tags != null:
				if i.tags != []:
					for v in i.tags:
						if v in new_text.to_lower():
							i.visible = true
	else:
		for i in $Main/WorkshopWindow/List/ScrollContainer/GridContainer.get_children():
			i.visible = true

var downloadlocation
var leaveout
var modname

func Workshop_PreDownload_pressed():
	for i in $Main/WorkshopWindow/List/ScrollContainer/GridContainer.get_children():
		if i.get_node("Selected").visible == true:
			$Main/WorkshopWindow/Confirmation/ModName.text = i.shortname
			$Main/WorkshopWindow/Confirmation.popup_centered()
			
func Workshop_NoDownload_pressed():
	$Main/WorkshopWindow/Confirmation.visible = false

func Workshop_Download_pressed():
	for i in $Main/WorkshopWindow/List/ScrollContainer/GridContainer.get_children():
		if i.get_node("Selected").visible == true:
			$OverlayLayer/Overlay.visible = true
			$OverlayLayer/Overlay/Downloading.visible = true
			$OverlayLayer/Overlay/RichTextLabel.visible = false
			leaveout = i.leaveout
			modname = i.shortname
			downloadlocation = Global.WorkingDirectory + "/NovetusFE/workshop/downloads/" + i.url.split("/")[-1]
			httprequests.ziphttp.connect("request_completed", self, "download_complete")
			httprequests.download(i.url, downloadlocation)
			
func download_complete(result, response_code, headers, body):
	print(downloadlocation)
	$OverlayLayer/Overlay.visible = false
	$OverlayLayer/Overlay/Downloading.visible = false
	$OverlayLayer/Overlay/RichTextLabel.visible = true
	$Main/WorkshopWindow/Confirmation.visible = false
	if not modname in Configs.DownloadedMods:
		Configs.DownloadedMods.append(modname)
	print("index ", httprequests.index)
	$OverlayLayer/Overlay/Downloading/Downloading.text = "Extracting..."
	$OverlayLayer/Overlay/Downloading/Bytes.bbcode_text = "[center]This may take a while, do not close the application"
	httprequests.extract(downloadlocation, Global.WorkingDirectory + "/", httprequests.index, leaveout)
	for i in $Main/WorkshopWindow/List/ScrollContainer/GridContainer.get_children():
		if i.shortname in Configs.DownloadedMods:
			i.get_node("Name").modulate = Color("20ff00")
	Configs.saveconfig()
	httprequests.ziphttp.disconnect("request_completed", self, "download_complete")
	


func Workshop_Generate_pressed():
	var json = {
  "shortname":'"' + str($Main/WorkshopWindow/Upload/Shortname.text) + '"',
  "longname":'"' + str($Main/WorkshopWindow/Upload/Longname.text) + '"',
  "description":'"' + str($Main/WorkshopWindow/Upload/Description.text) + '"',
  "creator":'"' + str($Main/WorkshopWindow/Upload/Creator.text) + '"',
  "tags":$Main/WorkshopWindow/Upload/Tags.text.split(", "),
  "url":'"' + str($Main/WorkshopWindow/Upload/URL.text) + '"',
  "iconurl":'"' + str($Main/WorkshopWindow/Upload/URL2.text) + '"',
  "leaveout":$Main/WorkshopWindow/Upload/Github.pressed
}
	$Main/WorkshopWindow/Upload/Output.text = str(json)
	OS.clipboard = str(json)


func Workshop_Upload_pressed():
	$Main/WorkshopWindow/Upload.popup_centered()
