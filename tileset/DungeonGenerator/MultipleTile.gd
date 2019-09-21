extends MultiMeshInstance

var _positions := Array() #PoolVector3Array()
signal on_translate_all

func insert(pos:Vector3):
	#print(self.name, " /insert : ", pos, " size =", _positions.size())
	_positions.append(pos)

func delete_tile_at(pos:Vector3):
	#print(self.name, " /delete_tile_at : ", pos, " size =", _positions.size())
	_positions.erase(pos)

func clear():
	#print(self.name, " /clear")
	_positions.clear()

func translate_all():
	var basis := Basis()
	var size:int = _positions.size()
	#print(self.name, " /translate_all - size : ", _positions.size())
	multimesh.instance_count = size
	for i in range(size):
		var pos:Vector3 = _positions[i]
		multimesh.set_instance_transform(i, Transform(basis,  pos))
		emit_signal("on_translate_all", pos)