extends TextureButton

export var shortname = "Test Item" # Title for your workshop mod
export var longname = "Test Item" # Long Title for your workshop mod
export var description = "A custom description for this addon, required you to scroll if too big!" # Description
export var creator = "by Creator" # Creator Field
export var tags = [] # Custom Search Tags
export var iconurl = "" # URL to Icon
export var url = "" # URL to download
export var leaveout = false # For github repositories, treats the first folder as if it were root.

var test = {
	"Data":
		[
			{
				"shortname":shortname,
				"longname":longname,
				"description":description,
				"creator":creator,
				"tags":tags,
				"url":url,
				"icon-url":iconurl,
				"leave-out":true
			},
		]
	}

func _ready():
	$Name.text = shortname
	$Description.text = description
	$Creator.text = creator
	if iconurl != "":
		httprequests.ziphttp.connect("request_completed", self, "download_complete")
		print(iconurl.split("/")[-1])
		httprequests.download(iconurl, Global.WorkingDirectory + "/NovetusFE/workshop/icons/" + iconurl.split("/")[-1])
		
func download_complete(result, response_code, headers, body):
	print("download completed for icon")
	texture_normal = Configs.pathtoimage(Global.WorkingDirectory + "/NovetusFE/workshop/icons/" + iconurl.split("/")[-1],[128,128])
	httprequests.ziphttp.disconnect("request_completed", self, "download_complete")

func _on_TextureButton_pressed():
	for i in get_parent().get_children():
		if i is TextureButton:
			i.get_node("Selected").visible = false
	$Selected.visible = true
