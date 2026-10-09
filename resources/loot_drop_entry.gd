extends Resource
class_name LootDropEntry

@export var drop_scene: PackedScene
@export_range(1, 100, 1, "or_greater") var weight: int = 1
