extends Node

var http = HTTPRequest.new()
var ziphttp = HTTPRequest.new()
var f = File.new()
var d = Directory.new()
var looptimer = Timer.new()

func _ready():
	looptimer.one_shot = false
	looptimer.connect("timeout", self, "looptimer_timeout")
	add_child(http)
	add_child(ziphttp)
	add_child(looptimer)
	http.connect("request_completed", self, "_http_request_completed")
	download("https://github.com/Lachrymogenic/NovetusFE-WS/archive/refs/heads/main.zip",Global.WorkingDirectory + "/NovetusFE/downloads/download.zip")
	#extract("res://downloads/test.zip", Global.WorkingDirectory + "/addons/", "index.txt")
func extract(path, folder, index):
	# Path = path to zip, folder = folder to extract to and index = place where you put your index.txt
	for i in uncompress(path, index).get_string_from_utf8().split("\n"):
		if i != "":
			print(i)
			var thing = ""
			var counter = 0
			for v in Array(i.split("/")):
				if v != i.split("/")[-1]:
					if counter == 0:
						thing = thing + v
					else:
						thing = thing + "/" + v
				counter += 1
			print(thing)
			if len(i.split("/")) >= 2:
				if !d.dir_exists(folder + thing):
					d.make_dir_recursive(folder + thing)
			f.open(folder + i,File.WRITE)
			f.store_buffer(uncompress("res://downloads/test.zip", str(i)))
			f.close()
	print("done")

func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8()).ip
	Global.PublicIP = response
	Configs.updateinfo()
	http.disconnect("request_completed", self, "_http_request_completed")
	
func _ziphttp_request_completed(result, response_code, headers, body):
	looptimer.stop()
	print("Download Complete")
	#extract(Global.WorkingDirectory + "/NovetusFE/downloads/download.zip", Global.WorkingDirectory, "index.txt")
	ziphttp.disconnect("request_completed", self, "_ziphttp_request_completed")
	
func looptimer_timeout():
	print(ziphttp.get_downloaded_bytes())
	print(ziphttp.get_body_size())
	var bodySize = ziphttp.get_body_size()
	var downloadedBytes = ziphttp.get_downloaded_bytes()
	var percent = int(downloadedBytes*100/bodySize)
	print(str(percent) + " downloaded")
	
func uncompress(path, filetoget):
	var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
	var loaded = gdunzip.load(path)
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
