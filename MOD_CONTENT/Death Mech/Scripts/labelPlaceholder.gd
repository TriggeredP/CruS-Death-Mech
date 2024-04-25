extends Label3D

export var labelText:String

func change_value(value):
	text = labelText.format({"VALUE":str(value)})
