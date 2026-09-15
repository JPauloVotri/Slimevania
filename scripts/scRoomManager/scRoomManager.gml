function RoomManager() constructor {
    var _matrix = [];

    for (var _i = real(room_first); _i <= real(room_last); _i++) {
        var _name = room_get_name(_i);

        if (string_pos("room_", _name) == 1) {
            var _splitedName = string_split(_name, "_");

            if (array_length(_splitedName) == 3) {
                array_push(_matrix, [ real(_splitedName[1]), real(_splitedName[2])]);
            }
        }
    };

    var _maxLine = array_reduce(
        _matrix,
        function(_last, _new) {
            return max(_last, _new[0]);
        },
        0
    ) + 1;
    var _maxColumn = array_reduce(
        _matrix,
        function(_last, _new) {
            return max(_last, _new[1]);
        },
        0
    ) + 1;

    var _finalMatrix = array_create(_maxLine, noone);

    for (var _i = 0; _i < _maxLine; _i++) {
        var _line = _finalMatrix[_i];

        for (var _j = 0; _j < _maxColumn; _j++) {
            for (var _k = 0; _k < array_length(_matrix); _k++) {
                var _column = [_i, _j];

                if (_line == noone) {
                    _line = [];
                }

                if (_matrix[_k][0] == _column[0] && _matrix[_k][1] == _column[1]) {
                    array_push(_line, _column);

                    break;
                }

                if (_k == array_length(_matrix) - 1) {
                    array_push(_line, noone);
                }
            }

            _finalMatrix[_i] = _line;
        }
    }

    global.matrix = _finalMatrix;

    /// Faz a troca da room
    function change_room(_actual_room, _dx, _dy) {
        var _roomName = room_get_name(_actual_room);
        var _roomMatrix = get_room_matrix(_roomName);

        _roomMatrix[0] += _dy;
        _roomMatrix[1] += _dx;

        var _newRoomName = "room_" + string(_roomMatrix[0]) + "_" + string(_roomMatrix[1]);
        var _room = asset_get_index(_newRoomName);

        room_goto(_room);
    }

    function get_room_matrix(_room_name) {
        var _stringMatrix = string_split(_room_name, "_", true, 1)[1];
        var _matrix = array_map(
            string_split(_stringMatrix, "_"),
            function(_item) {
                return real(_item);
            }
        );

        return _matrix;
    }
}
