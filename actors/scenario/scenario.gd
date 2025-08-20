extends Node
enum ActionType { COMMAND, ACTIVATE, COMMENTARY, WAIT }

@export var steps: Array[ScenarioStep] = []
var current_step: int = 0

func _ready():
	process_step()

func process_step():
	if current_step >= steps.size():
		return
	var step: ScenarioStep = steps[current_step]
	print("Processing step %d: %s" % [current_step, step.action])
	match step.action:
		ActionType.COMMAND:
			print("Executing command on node: %s" % step.target)
			var node = get_node(step.target)
			if node and node.has_method("command"):
				print("Commanding node: %s with params: %s" % [node.name, step.params])
				node.command_parametrically(step.params.get("type", ""), step.params)
			continue_to_next_step()
		ActionType.ACTIVATE:
			print("Activating node: %s" % step.target)
			var node = get_node(step.target)
			if node and node.has_method("activate"):
				node.activate()
			continue_to_next_step()
		ActionType.COMMENTARY:
			print(step.params.get("text", ""))
			continue_to_next_step()
		ActionType.WAIT:
			print("Waiting for %s seconds..." % step.params.get("duration", 1.0))
			var duration = step.params.get("duration", 1.0)
			await get_tree().create_timer(duration).timeout
			print("Wait completed, continuing to next step.")
			continue_to_next_step()
		_:
			print("Unknown action: %s" % str(step.action))
			continue_to_next_step()

func continue_to_next_step():
	current_step += 1
	process_step()
