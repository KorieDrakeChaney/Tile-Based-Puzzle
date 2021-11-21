extends Spatial

export (PackedScene) var CubeScn;
var cubes : Array = [];


onready var Camera : Camera = $Camera
onready var successAudio : AudioStreamPlayer = $Success;
onready var backgroundAudio : AudioStreamPlayer = $Background;


var width : int;
var height : int;

var head = 0;
var tail : Array = [];
var blockedPos : Array = [];
var blocked : Array = [];


var right = head + height;
var left = head - height;
var up = head - 1;
var down = head + 1;

var success : bool = false;
var defeat : bool = false;


onready var levels = File.new()
var level : int = 1;
var maxLevel : int = 3;
var dictionary = {};

func _ready():
	if levels.open("res://src/levels/levels.json", File.READ) == OK:
		var text = levels.get_as_text();
		levels.close()
		dictionary = JSON.parse(text).result;
	
	loadLevel(level);
	
	yield(get_tree().create_timer(0.5), "timeout");
	backgroundAudio.play();

func _physics_process(delta):
	if !success && !defeat:
		if head.selected:
			tileSelect();
		for cube in tail: 
			if cube.activeFinished:
				cube.animation.play("idle");

		if tail.size() > 1: if tail.back().activeFinished:
			head.animation.play("idle");
			failure(0.5);
		head.animation.play("active");
	
func tileSelect():
	
	right = [head.position[0] + 1, head.position[1]];
	left = [head.position[0] - 1, head.position[1]];
	up = [head.position[0], head.position[1] - 1];
	down = [head.position[0], head.position[1] + 1];
	
	for cube in cubes:
		if cube.selected:
			if cube.position == right|| cube.position == left || cube.position == up || cube.position == down:
				if(!tail.has(cube) && !blocked.has(cube)):
					cube.audio.play();
					cube.selected = false;
					head.selected = false;
					tail.append(head);
					head = cube;
					checkGrid();
					break;


func body():
	for block in blocked:
		block.material.albedo_color = Color(0.2, 0.2, 0.2);


func victory():
	if level < maxLevel:
		level += 1;
	success = true;
	successAudio.play();
	yield(get_tree().create_timer(3.0), "timeout");
	loadLevel(level);

func failure(timeout):
	yield(get_tree().create_timer(timeout), "timeout");
	get_tree().reload_current_scene();

func loadLevel(level):
	
	# clears
	for cube in cubes:
		remove_child(cube);
		cube.queue_free();
		
	cubes.clear();
	tail.clear();
	blocked.clear();
	
	width = int(dictionary[String(level)].width);
	height = int(dictionary[String(level)].height);
	
	for x in range(width):
		for z in range(height):
			var cube = CubeScn.instance();
			cube.scale = Vector3(0.5, 0.5, 0.5);
			cube.translation = Vector3(1 + (1.05 * x), 0, 0 + (1.05 * z));
			cube.position = [x + 1, z + 1];
			add_child(cube);
			cubes.append(cube);
	
	blockedPos = parse_json(dictionary[String(level)]["blocked"]);
	
	for block in blockedPos:
		for cube in cubes:
			if block[0] == cube.position[0] && block[1] == cube.position[1]:
				blocked.append(cube);
				
	head = cubes[0];
	Camera.translation = Vector3(1 + (width / 2), (width / 2 + height / 2) + 1, height / 2.5);
	Camera.rotation_degrees = Vector3(-90, 0, 0);
	
	body();
	
	defeat = false;
	success = false;

	
	head.animation.play("active");
	

func checkGrid():
	right = [head.position[0] + 1, head.position[1]];
	left = [head.position[0] - 1, head.position[1]];
	up = [head.position[0], head.position[1] - 1];
	down = [head.position[0], head.position[1] + 1];
	
	
	var activeCorners = [];
	
	if head.position[0] <= width - 1:
		activeCorners.append(right);
	if head.position[0] >= 2:
		activeCorners.append(left);
	if head.position[1] <= height - 1:
		activeCorners.append(down);
	if head.position[1] >= 2:
		activeCorners.append(up);

	var check = 0;
	for i in range(activeCorners.size()):
		for cube in tail:
			if cube.position == activeCorners[i]:
				check += 1;
		for block in blocked:
			if block.position == activeCorners[i]:
				check += 1;
	
	var count = 0;
	for cube in cubes:
		if tail.has(cube):
			count += 1;

	if check == activeCorners.size() && count == width * height - 1 - blocked.size():
		victory();
	elif check == activeCorners.size():
		failure(1.5);
	
