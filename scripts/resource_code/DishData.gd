extends Resource
class_name DishData

@export var dish_name: String = "Unknown Dish"
@export var base_volume_fill: float = 15.0
@export var choke_penalty: float = 5.0
@export var nausea_penalty: float = 0.0
@export var hardness_factor: float = 1.0
@export var restricted_buttons: Array[String] = []
@export var dish_icon: Texture2D # Drag and drop the UI icon directly here
