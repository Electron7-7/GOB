extends Control

# Dump given mesh to obj file
func save_mesh_to_obj(mesh, file_name, object_name):

	# Object definition
	var _output = "o " + object_name + "\n"

	# Write all surfaces in mesh (obj file indices start from 1)
	var index_base = 1
	for s in range(mesh.get_surface_count()):

		var surface = mesh.surface_get_arrays(s)
		if surface[ArrayMesh.ARRAY_INDEX] == null:
			push_warning("Saving only supports indexed meshes for now, skipping non-indexed surface " + str(s))
			continue

		_output += "g surface" + str(s) + "\n"

		for v in surface[ArrayMesh.ARRAY_VERTEX]:
			_output += "v " + str(v.x) + " " + str(v.y) + " " + str(v.z) + "\n"

		var has_uv = false
		if surface[ArrayMesh.ARRAY_TEX_UV] != null:
			for uv in surface[ArrayMesh.ARRAY_TEX_UV]:
				_output += "vt " + str(uv.x) + " " + str(1.0 - uv.y) + "\n"
			has_uv = true

		var has_n = false
		if surface[ArrayMesh.ARRAY_NORMAL] != null:
			for n in surface[ArrayMesh.ARRAY_NORMAL]:
				_output += "vn " + str(n.x) + " " + str(n.y) + " " + str(n.z) + "\n"
			has_n = true

		# Write triangle faces
		# Note: Godot's front face winding order is different from obj file format
		var i = 0
		var indices = surface[ArrayMesh.ARRAY_INDEX]
		while i < indices.size():

			_output += "f " + str(index_base + indices[i])
			if has_uv:
				_output += "/" + str(index_base + indices[i])
			if has_n:
				if not has_uv:
					_output += "/"
				_output += "/" + str(index_base + indices[i])

			_output += " " + str(index_base + indices[i + 2])
			if has_uv:
				_output += "/" + str(index_base + indices[i + 2])
			if has_n:
				if not has_uv:
					_output += "/"
				_output += "/" + str(index_base + indices[i + 2])

			_output += " " + str(index_base + indices[i + 1])
			if has_uv:
				_output += "/" + str(index_base + indices[i + 1])
			if has_n:
				if not has_uv:
					_output += "/"
				_output += "/" + str(index_base + indices[i + 1])

			_output += "\n"

			i += 3

		index_base += surface[ArrayMesh.ARRAY_VERTEX].size()

	var file = FileAccess.open("res://" + file_name, FileAccess.WRITE)
	file.store_string(_output)
	file.close()
