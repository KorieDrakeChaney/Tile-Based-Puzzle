extends Control

onready var Start : Button = $VBoxContainer/StartButton;
onready var Quit : Button = $VBoxContainer/QuitButton;


func _on_StartButton_pressed():
	get_tree().change_scene("res://src/Main.tscn");



func _on_QuitButton_pressed():
	get_tree().quit()
