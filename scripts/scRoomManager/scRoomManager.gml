function RoomManager() constructor {
	var _matriz = [];
	
	for (var _i = real(room_first); _i <= real(room_last); _i++) {
		var _name = room_get_name(_i);
		
		if (string_pos("room_", _name) == 1) {
			var _splitedName = string_split(_name, "_");
			
			if (array_length(_splitedName) == 3) {
				array_push(_matriz, [ real(_splitedName[1]), real(_splitedName[2])]);
			}
		}
	};
	
	var _max_line = array_reduce(_matriz, function(_last, _new) { return max(_last, _new[0]) }, 0) + 1;
	var _max_column = array_reduce(_matriz, function(_last, _new) { return max(_last, _new[1]) }, 0) + 1;
	
	var _final_matrix = array_create(_max_line, noone);
	
	for (var _i = 0; _i < _max_line; _i++) {
		var _line = _final_matrix[_i];
		
		for (var _j = 0; _j < _max_column; _j++) {
			for (var _k = 0; _k < array_length(_matriz); _k++) {
				var _column = [_i, _j];
				
				if (_line == noone) {
					_line = [];
				}
				
				if (_matriz[_k][0] == _column[0] && _matriz[_k][1] == _column[1]) {
					array_push(_line, _column);
					
					break;
				}
				
				if (_k == array_length(_matriz) - 1) {
					array_push(_line, noone);
				}
			}
			
			_final_matrix[_i] = _line;
		}
	}
	
	global.matrix = _final_matrix;
	
	/// Faz a troca da room
	function change_room(_actual_room, _dx, _dy) {
		var _room_name = room_get_name(_actual_room);
		var _room_matrix = get_room_matrix(_room_name);
		
		_room_matrix[0] += _dy;
		_room_matrix[1] += _dx;
		
		var _new_room_name = "room_" + string(_room_matrix[0]) + "_" + string(_room_matrix[1]);
		var _room = asset_get_index(_new_room_name);		
		
		room_goto(_room);
	}
	
	function get_room_matrix(_room_name) {
		var _string_matrix = string_split(_room_name, "_", true, 1)[1];
		var _matrix = array_map(string_split(_string_matrix, "_"), function(_item) { return real(_item) });
		
		return _matrix;
	}
}