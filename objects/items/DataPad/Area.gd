extends Area


func use(actor) -> bool:
	return get_parent().use(actor)
