extends Node

var http = HTTPRequest.new()
var ziphttp = HTTPRequest.new()
var storehttp = HTTPRequest.new()
var f = File.new()
var d = Directory.new()
var looptimer = Timer.new()

var index = []

onready var workshopfolder = Global.WorkingDirectory + "/NovetusFE/workshop"

func _ready():
	looptimer.one_shot = false
	looptimer.connect("timeout", self, "looptimer_timeout")
	add_child(http)
	add_child(ziphttp)
	add_child(storehttp)
	add_child(looptimer)
	http.connect("request_completed", self, "_http_request_completed")
	#download("https://github.com/Lachrymogenic/NovetusFE-WS/archive/refs/heads/main.zip", workshopfolder + "/downloads/download.zip")
	#extract("res://downloads/test.zip", Global.WorkingDirectory + "/addons/", "index.txt")
func extract(path, folder, index, leaveout=false):
	uncompress(path, "any")
	# Path = path to zip, folder = folder to extract to and index = place where you put your index.txt
	print("extract running ", index)
	for i in index:
		if i != "":
			print(i)
			var thing = ""
			var counter = 0
			var end = ""
			for v in Array(i.split("/")):
				if v != i.split("/")[-1]:
					if counter == 0:
						if leaveout == false:
							thing = thing + v
						else:
							thing = thing + i.split("/")[1]
					else:
						if leaveout == false:
							thing = thing + "/" + v
						else:
							if v == i.split("/")[1]:
								thing = thing + "/"
								#leaveout = false
							else:
								thing = thing + v + "/"
				else:
					end = v
				counter += 1
			if leaveout == true:
				print(folder + thing + end)
				pass
			else:
				pass
				#print(folder + i)
			if len(i.split("/")) >= 2:
				if "/" in thing:
					if !d.dir_exists(folder + thing):
						d.make_dir_recursive(folder + thing)
			if leaveout == false:
				f.open(folder + i,File.WRITE)
				f.store_buffer(uncompress(path, str(i)))
				f.close()
			else:
				if end == thing: end = ""
				if len(i.split("/")) >= 3:
					f.open(folder + thing + end,File.WRITE)
					f.store_buffer(uncompress(path, str(i)))
					f.close()
	#print("done")

func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8()).ip
	Global.PublicIP = response
	Configs.updateinfo()
	http.disconnect("request_completed", self, "_http_request_completed")
	
func _ziphttp_request_completed(result, response_code, headers, body):
	looptimer.stop()
	print("ziphttp: Download Complete")
	#extract(Global.WorkingDirectory + "/NovetusFE/downloads/download.zip", Global.WorkingDirectory, "index.txt")
	ziphttp.disconnect("request_completed", self, "_ziphttp_request_completed")
	
func looptimer_timeout():
	Global.Main.get_node("OverlayLayer/Overlay/Downloading/Downloading").text = "Downloading..."
	var node = Global.Main.get_node("OverlayLayer/Overlay/Downloading/Bytes")
	print("looptimer ", ziphttp.get_downloaded_bytes())
	node.bbcode_text = "[center]" + str(float(ziphttp.get_downloaded_bytes() / 1000000)) + "."
	if str(ziphttp.get_downloaded_bytes() / 1000).length() >= 4:
		node.bbcode_text = node.bbcode_text + str(ziphttp.get_downloaded_bytes() / 1000).substr(1, -1)
	else:
		node.bbcode_text = node.bbcode_text + str(ziphttp.get_downloaded_bytes() / 1000)
	node.bbcode_text = node.bbcode_text + " MBs"
	print(ziphttp.get_body_size())
	var bodySize = ziphttp.get_body_size()
	var downloadedBytes = ziphttp.get_downloaded_bytes()
	var percent = int(downloadedBytes*100/bodySize)
	print(str(percent) + " downloaded")
	
func uncompress(path, filetoget):
	var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
	var loaded = gdunzip.load(path)
	index.clear()
	for i in gdunzip.files:
		if !i.ends_with("/"):
			index.append(i)
	#print(index)
	if loaded:
		var uncompressed = gdunzip.uncompress(filetoget)
		if !uncompressed:
			print('Failed uncompressing requested file.')
		else:
			return uncompressed
	else:
		print('Failed loading zip file.')

func download(url : String, target : String):
	looptimer.start(0.5)
	ziphttp.connect("request_completed", self, "_ziphttp_request_completed")
	ziphttp.download_file = target # where to save the downloaded file
	ziphttp.request(url) # start the download
	
func _storehttp_request_completed(result, response_code, headers, body):
	populateworkshoplist()
	storehttp.disconnect("request_completed", self, "_storehttp_request_completed")
	
func populateworkshoplist():
	uncompress(Global.WorkingDirectory + "/NovetusFE/workshop/downloads/repository.zip","any")
	for i in Global.Main.get_node("Main/WorkshopWindow/List/ScrollContainer/GridContainer").get_children():
		i.queue_free()
	for i in index:
		if i.ends_with(".json"):
			var response = parse_json(uncompress(Global.WorkingDirectory + "/NovetusFE/workshop/downloads/repository.zip", i).get_string_from_utf8())
			var button = preload("res://scenes/objects/cus_ws_button.tscn").instance()
			button.shortname = response.shortname
			button.description = response.description
			button.creator = response.creator
			button.tags = response.tags
			button.iconurl = response.iconurl 
			button.url = response.url
			button.leaveout = response.leaveout
			Global.Main.get_node("Main/WorkshopWindow/List/ScrollContainer/GridContainer").add_child(button)
			yield(get_tree().create_timer(0.5),"timeout")
	Global.Main.get_node("Main/WorkshopWindow/List").visible = true
	for i in Global.Main.get_node("Main/WorkshopWindow/List/ScrollContainer/GridContainer").get_children():
		if i.shortname in Configs.DownloadedMods:
			i.get_node("Name").modulate = Color("20ff00")
	
func get_store():
	storehttp.connect("request_completed", self, "_storehttp_request_completed")
	storehttp.download_file = Global.WorkingDirectory + "/NovetusFE/workshop/downloads/repository.zip"
	storehttp.request(Configs.WorkshopRepo)
