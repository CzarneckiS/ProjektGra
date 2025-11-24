
class_name TestScript

#to jest klasa w ktorej prowadze eksperymenty / debugguje
#move along

#bardzo przydatna funkcja do testowania czy RefCounted zostal zwolniony
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("Bye")
