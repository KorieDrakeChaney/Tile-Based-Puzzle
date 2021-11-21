extends Area

onready var cubeMesh : MeshInstance = $CubeMesh;
onready var collider : CollisionShape = $Collider;
onready var material = cubeMesh.get_surface_material(0);
onready var audio : AudioStreamPlayer = $Audio;
onready var animation : AnimationPlayer = $Animation;

var mouseHeld : bool;

var selected : bool = false;

var position : Array = [];

var activeFinished : bool = false;
var finished : bool = false;

func _ready():
	material.albedo_color = Color(1, 1, 1);

func _unhandled_input(event):
	if event.is_action_pressed("Clicked"):
		mouseHeld = true;
	if event.is_action_released("Clicked"):
		mouseHeld = false;
		selected = false;

func animate():
	animation.play("activate");

func _on_Cube_input_event(camera, event, click_position, click_normal, shape_idx):
	if mouseHeld:
		selected = true;


func _on_Animation_animation_finished(anim_name):
	if anim_name == "active":
		activeFinished = true;
	finished = true;


func _on_Animation_animation_started(anim_name):
	finished = false;
	if anim_name == "active":
		activeFinished = false;



