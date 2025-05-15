extends Node

var score = 0
var time_elapsed = 0.0
var timer_running = true

@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel

func _process(delta):
	if timer_running:
		time_elapsed += delta
		timer_label.text = "Time: " + str("%.2f" % time_elapsed) + "s"

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins out of 18."

# Called when the player enters the finish area
func _on_finish_area_body_entered(body):
	if body.name == "Player":  # Adjust 'Player' if your node is named differently
		timer_running = false
		timer_label.text += "  (Finished!)"
