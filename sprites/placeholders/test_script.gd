extends Node
class_name TestScript

#to jest klasa w ktorej prowadze eksperymenty / debugguje
#move along

var object = SkeletonMageProjectileScene

var ref = weakref(object)

func _process(_delta):
	print("test")
