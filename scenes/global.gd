extends Node

onready var WorkingDirectory = OS.get_executable_path().get_base_dir()
var f = File.new()
var dir = Directory.new()
var Drive = "Z:"
var PublicIP = ""
onready var Main = get_node("/root/Main")

func _ready():
	if !f.file_exists(WorkingDirectory + "/bin/Novetus.exe"):
		WorkingDirectory = OS.get_executable_path().get_base_dir() + "/.."
		print(WorkingDirectory)
	if f.file_exists(WorkingDirectory + "/bin/Novetus.exe"):
		Main.get_node("Main").visible = true
		print("visible")
	else:
		Main.get_node("Main").visible = false
		Main.get_node("Background/FirstTime").visible = false
		Main.get_node("Background/Info").visible = false
	if !f.file_exists(WorkingDirectory + "/bin/Novetus.exe"): return
	match OS.get_name():
		"X11":
			print("yea")
			Drive = "Z:"
			f.open(WorkingDirectory + "/Start.sh", File.WRITE)
			f.store_string('#!/bin/bash\nif [ -z "$4" ]; then WINEPREFIX="$1" "$2" "$3"; else WINEPREFIX="$1" "$2" "$3" "$4"; fi')
			f.close()
			Main.get_node("Background/FirstTime/Panel/TabContainer").current_tab = 0
		"Windows":
			Drive = "C:"
			Main.get_node("Background/FirstTime/Panel/TabContainer").current_tab = 1
			Main.get_node("Main/Settings/ItemList").remove_item(0)
		_:
			Main.get_node("Background/Control2/RichTextLabel").text = "Your operating system is not supported.\nLinux and Windows only."
			Main.get_node("Main").visible = false
	if !dir.dir_exists(WorkingDirectory + "/NovetusFE"): dir.make_dir(WorkingDirectory + "/NovetusFE")
	if !dir.dir_exists(WorkingDirectory + "/NovetusFE/themes"): dir.make_dir(WorkingDirectory + "/NovetusFE/themes")
