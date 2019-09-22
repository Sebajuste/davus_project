extends MultiMeshInstance

var _positions := Dictionary() #PoolVector3Array()
signal on_translate

func insert(pos:Vector3, angle_z: float = 0):
	#print(self.name, " /insert : ", pos, " size =", _positions.size())
	_positions[pos] = angle_z

func delete_tile_at(pos:Vector3):
	#print(self.name, " /delete_tile_at : ", pos, " size =", _positions.size())
	_positions.erase(pos)

func clear():
	#print(self.name, " /clear")
	_positions.clear()

func translate_all():
	#print(self.name, " /translate_all - size : ", _positions.size())
	multimesh.instance_count = _positions.size()
	var i:int = 0
	for pos in _positions.keys():
		var angle_z:float = _positions[pos]
		multimesh.set_instance_transform(i, Transform(Basis(Vector3.FORWARD, angle_z), pos))
		emit_signal("on_translate", self, pos, angle_z)
		i += 1