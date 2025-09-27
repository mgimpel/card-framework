class_name Statistics
extends Control


var record_table: Dictionary[String, Dictionary] = {}
var menu_scene: PackedScene = load("res://freecell/scenes/menu/menu.tscn")
var record_node: PackedScene = preload("res://freecell/scenes/menu/record.tscn")


@onready var records_node: Node = $Panel/VBox/Records/VBoxContainer
@onready var summary_node: Node = $Panel/VBox/Summary


func _ready() -> void:
	_get_record_table()
	_set_summary()
	_set_records()
	_set_ui()


func _get_record_table() -> void:
	var node := get_tree().root.get_node("RecordManager")
	var record_manager := node as RecordManager
	record_table = record_manager.get_all_records()


func _set_ui() -> void:
	var button_menu: Button = $ButtonMenu
	button_menu.connect("pressed", _go_to_menu)


func _set_records() -> void:
	var keys: Array[String] = record_table.keys()
	for i in range(keys.size() - 1, -1, -1):
		var record_id := keys[i]
		var record := record_table[record_id]
		_make_record(record)


func _make_record(record: Dictionary) -> void:
	var date_info := record["game_date"] as Dictionary
	var year := date_info["year"] as int
	var month := date_info["month"] as int
	var day := date_info["day"] as int
	var h := date_info["hour"] as int
	var mi := date_info["minute"] as int
	var s := date_info["second"] as int
	var date := "%04d-%02d-%02d %02d:%02d:%02d" % [year, month, day, h, mi, s]
	var result := ""
	if record["game_state"] == FreecellGame.GameState.WIN:
		result = "Win"
	elif record["game_state"] == FreecellGame.GameState.LOSE:
		result = "Lose"
	var game_seed := str(record["game_seed"])
	var score := str(record["score"])
	var move := str(record["move_count"])
	var undo := str(record["undo_count"])
	var game_time := str(record["game_time"])
	
	var record_instance := record_node.instantiate()
	record_instance.get_node("Date").text = date
	record_instance.get_node("Result").text = result
	record_instance.get_node("Seed").text = game_seed
	record_instance.get_node("Score").text = score
	record_instance.get_node("Move").text = move
	record_instance.get_node("Undo").text = undo
	record_instance.get_node("Time").text = game_time
	records_node.add_child(record_instance)


func _set_summary() -> void:
	var game_count := 0
	var win_count := 0
	var lose_count := 0
	
	for record_id in record_table.keys():
		var record := record_table[record_id]
		game_count += 1
		if record["game_state"] == FreecellGame.GameState.WIN:
			win_count += 1
		elif record["game_state"] == FreecellGame.GameState.LOSE:
			lose_count += 1
	
	var win_rate := 0
	if game_count != 0:
		win_rate = int(float(win_count) / float(game_count) * 100)
	
	var game_played_node := summary_node.get_node("GamePlayed")
	var wins_node := summary_node.get_node("Wins")
	var loses_node := summary_node.get_node("Loses")
	var win_rate_node := summary_node.get_node("WinRate")
	
	game_played_node.text = "Games Played: %d" % game_count
	wins_node.text = "Wins: %d" % win_count
	loses_node.text = "Loses: %d" % lose_count
	win_rate_node.text = "Win Rate: %d%%" % win_rate


func _go_to_menu() -> void:
	var menu_instance := menu_scene.instantiate()
	get_tree().root.add_child(menu_instance)
	get_node("/root/Statistics").queue_free()
