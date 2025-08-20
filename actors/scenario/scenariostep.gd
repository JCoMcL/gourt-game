extends Resource
class_name ScenarioStep

enum ActionType { COMMAND, ACTIVATE, COMMENTARY, WAIT }

@export var action: ActionType = ActionType.COMMAND
@export var target: NodePath
@export var params: Dictionary = {}
