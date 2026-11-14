/// Gerencia a navegação entre salas.
function RoomManager() constructor {
    destroyedInstances = {};
    map = new Map();
    hiddenRooms = [
        room_0_1,
    ]
    hasNeighbor = {
        left: false,
        right: false,
        top: false,
        bottom: false,
    }

    /// Busca a sala correspondente à posição de coordenadas do mapa.
    /// @param {Struct.Vector2} _position Posição da sala no mapa, em coordenadas de sala.
    /// @returns {Asset.GMRoom|Undefined} A sala encontrada para a posição, ou `undefined` se não existir.
    get_room_on_position = function(_position) {
        var _roomName = "room_" + string(_position.x) + "_" + string(_position.y);
        _roomName = string_replace_all(_roomName, "-", "n");
        var _room = asset_get_index(_roomName);

        if (_room < 0) return;

        return _room;
    }

    /// Muda para a sala na direção informada.
    /// @param {Struct.Vector2} _transitionDir Direção da transição.
    change_room = function(_transitionDir) {
        if (_transitionDir.magnitude() == 0) return;

        var _roomPos = get_current_room_position().addRW(_transitionDir);
        var _room = get_room_on_position(_roomPos);

        if (is_undefined(_room)) {
            show_debug_message("Não existe sala na posição " + string(_roomPos));
            return;
        }

        room_goto(_room);
		
		var _transitionError = new Vector2(-32, -32);
		_transitionError.componentMultiplyRW(_transitionDir.sign());

        if (instance_exists(oPlayer)) {
            oPlayer.x -= (_transitionDir.x * room_width) + _transitionError.x;
            oPlayer.y -= (_transitionDir.y * room_height) + _transitionError.y;
        }
    }

    /// Retorna as coordenadas de uma sala específica.
    /// @param {Asset.GMRoom|Real} _room A sala ou o índice da sala.
    /// @returns {Struct.Vector2} A posição da sala informada.
    get_room_position = function(_room) {
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

        var _roomName = room_get_name(_room);
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

    /// Retorna as coordenadas da sala atual.
    /// @returns {Struct.Vector2} A posição da sala atual.
    get_current_room_position = function () {
        return get_room_position(room);
    }

    /// Registra uma instância como destruída e a remove.
    /// @param {Id.Instance} _instance Instância a ser destruida e registrada.
    destroy_instance_and_persist = function(_instance) {
        var _roomName = room_get_name(room);

        if (!variable_struct_exists(destroyedInstances, _roomName)) {
            destroyedInstances[$ _roomName] = [];
        }

        array_push(
            destroyedInstances[$ _roomName],
            [_instance.object_index, _instance.x, _instance.y]
        );

        instance_destroy(_instance, false);
    }

    /// Restaura o estado da sala atual, destruindo instâncias já destruídas.
    restore_room = function() {
        var _roomName = room_get_name(room);

        map.set_room_tile_visited(get_current_room_position());

        if (!variable_struct_exists(destroyedInstances, _roomName)) {
            return;
        }

        var _list = destroyedInstances[$ _roomName];

        for (var _i = 0; _i < array_length(_list); _i++) {
            var _entry = _list[_i];

            var _object = _entry[0];
            var _x = _entry[1];
            var _y = _entry[2];

            /// @self Asset.GMObject
            with (_object) {
                if (x == _x && y == _y) {
                    instance_destroy();
                }
            }
        }
    }
	
	/// Verifica se uma instância foi registrada como destruída.
	/// @param {Id.Instance} _instance Instância a verificar.
	/// @returns {Bool}
	is_instance_destroyed = function(_instance) {
	    var _roomName = room_get_name(room);

	    if (!variable_struct_exists(destroyedInstances, _roomName)) {
	        return false;
	    }

	    var _list = destroyedInstances[$ _roomName];

	    for (var _i = 0; _i < array_length(_list); _i++) {
	        var _entry = _list[_i];

	        if (
	            _entry[0] == _instance.object_index &&
	            _entry[1] == _instance.x &&
	            _entry[2] == _instance.y
	        ) {
	            return true;
	        }
	    }

	    return false;
	}
	
	/// Registra a destruição de um objeto em uma room específica.
	/// @param {Asset.GMRoom} _room
	/// @param {Asset.GMObject} _object
	/// @param {Real} _x
	/// @param {Real} _y
	register_destroyed_instance = function(_room, _object, _x, _y) {
	    var _roomName = room_get_name(_room);

	    if (!variable_struct_exists(destroyedInstances, _roomName)) {
	        destroyedInstances[$ _roomName] = [];
	    }

	    var _list = destroyedInstances[$ _roomName];

	    // Evita registros duplicados.
	    for (var _i = 0; _i < array_length(_list); _i++) {
	        var _entry = _list[_i];

	        if (
	            _entry[0] == _object &&
	            _entry[1] == _x &&
	            _entry[2] == _y
	        ) {
	            return;
	        }
	    }

	    array_push(
	        destroyedInstances[$ _roomName],
	        [_object, _x, _y]
	    );
	}
	
	/// Destrói um bloco e sincroniza com as rooms vizinhas.
	/// @param {Id.Instance} _instance Bloco a ser destruído.
	destroy_connected_block = function(_instance) {
	    var _object = _instance.object_index;
	    var _x = _instance.x;
	    var _y = _instance.y;

	    // Registra a destruição na room atual.
	    register_destroyed_instance(room, _object, _x, _y);

	    var _roomPos = get_current_room_position();

	    var _blockSize = 32;

	    // Direções: direita, baixo, esquerda, cima.
	    var _directions = [
	        new Vector2(1, 0),
	        new Vector2(0, 1),
	        new Vector2(-1, 0),
	        new Vector2(0, -1)
	    ];

	    for (var _i = 0; _i < array_length(_directions); _i++) {
	        var _dir = _directions[_i];

	        var _neighborRoom = get_room_on_position(
	            _roomPos.copy().addRW(_dir)
	        );

	        if (is_undefined(_neighborRoom)) {
	            continue;
	        }

	        var _neighborX = _x;
	        var _neighborY = _y;
	        var _connected = false;

	        // Direita -> esquerda da room vizinha.
	        if (_dir.x == 1 && _x >= room_width - _blockSize) {
	            _neighborX = 0;
	            _connected = true;
	        }

	        // Esquerda -> direita da room vizinha.
	        if (_dir.x == -1 && _x <= 0) {
	            _neighborX = room_get_width(_neighborRoom) - _blockSize;
	            _connected = true;
	        }

	        // Baixo -> cima da room vizinha.
	        if (_dir.y == 1 && _y >= room_height - _blockSize) {
	            _neighborY = 0;
	            _connected = true;
	        }

	        // Cima -> baixo da room vizinha.
	        if (_dir.y == -1 && _y <= 0) {
	            _neighborY = room_get_height(_neighborRoom) - _blockSize;
	            _connected = true;
	        }

	        if (_connected) {
	            register_destroyed_instance(
	                _neighborRoom,
	                _object,
	                _neighborX,
	                _neighborY
	            );
	        }
	    }

	    instance_destroy(_instance, false);
	}

    /// Atualiza os flags de vizinhança da sala atual.
    update_neighbor_flags = function() {
        var _roomPos = get_current_room_position();
        var _dir = new Vector2(1, 0);
        var _keys = ["right", "bottom", "left", "top"];
        var _halfPi = pi / 2;

        for (var _i = 0; _i < 4; _i++) {
            var _neighborPosition = _roomPos.copy().addRW(_dir);
            var _room = get_room_on_position(_neighborPosition);

            hasNeighbor[$ _keys[_i]] = !is_undefined(_room);

            // Rotaciona 90° e arredonda para evitar erros de ponto flutuante.
            _dir.rotateRW(_halfPi).rndRW();
        }
    }

    /// Cria no mapa uma tile para cada sala do jogo.
    map_rooms = function() {
        for (var _room = real(room_first); _room <= real(room_last); _room++) {
            var _position = get_room_position(_room);
            var _isHidden = array_contains(hiddenRooms, _room);
            var _tile = new MapTile(false, _isHidden, MAP_ZONE.BLUE);

            map.add_tile(_position, _tile);
        }
    }

    map_rooms();
}
