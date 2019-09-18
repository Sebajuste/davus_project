extends Spatial

export var minScaleMod =  .25
export var maxScaleMod = 1.75

func _ready():
	
	var plant
	var scale
	var mod
	
	mod = rand_range(minScaleMod, maxScaleMod)
	
	plant = find_node("model")
	scale = plant.transform.basis.get_scale()
	plant.transform = plant.transform.scaled(scale * mod)
	
	plant = find_node("model2")
	scale = plant.transform.basis.get_scale()
	plant.transform = plant.transform.scaled(scale * mod)
		