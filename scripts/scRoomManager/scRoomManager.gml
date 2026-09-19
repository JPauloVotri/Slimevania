/// Gerencia a navegação entre salas.
function RoomManager() constructor {
    /* TODO: Avaliar necessidade
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
    */

    /**
     * Muda para a sala na direção informada.
     * @param {Struct.Vector2} _transitionDir Direção da transição.
     */
    change_room = function(_transitionDir) {
        if (_transitionDir.magnitude() == 0) return;

        var _roomPos = get_room_position().addRW(_transitionDir);
        var _roomName = "room_" + string(_roomPos.x) + "_" + string(_roomPos.y);
        _roomName = string_replace_all(_roomName, "-", "n");

        room_goto(asset_get_index(_roomName));

        if (instance_exists(oPlayer)) {
            oPlayer.x -= _transitionDir.x * room_width;
            oPlayer.y -= _transitionDir.y * room_height;
        }
    }

    /**
     * Retorna as coordenadas da sala atual.
     * @returns {Struct.Vector2} A posição da sala atual.
     */
    get_room_position = function () {
        /**
         * Converte uma coordenada textual em número.
         * @param {String} _str Coordenada em formato textual.
         * @return {Real} Coordenada em formato numérico.
         */
        var _parse_coord = function(_str) {
            if (string_starts_with(_str, "n")) {
                return -real(string_delete(_str, 1, 1));
            }

            return real(_str);
        }

        var _roomName = room_get_name(room);
        var _parts = string_split(_roomName, "_");
        var _last = array_length(_parts) - 1;

        if (array_length(_parts) < 3) {
            show_debug_message("Nome de sala inválido: " + _roomName);
            return new Vector2(0, 0);
        }

        return new Vector2(
            _parse_coord(_parts[_last - 1]),
            _parse_coord(_parts[_last])
        );
    }
}
