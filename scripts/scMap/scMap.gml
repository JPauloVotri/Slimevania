/// Estrutura que armazena as tiles do mapa por posição.
function Map() constructor {
    tiles = {};
    limits = {
        left: infinity,
        right: -infinity,
        top: infinity,
        bottom: -infinity,
    }

    /// Adiciona uma tile ao mapa.
    /// @param {Struct.Vector2} _position A posição da tile no mapa.
    /// @param {Struct.MapTile} _tile A tile do mapa.
    add_tile = function(_position, _tile) {
        var _index = string(_position)

        tiles[$ _index] = _tile;

        if (_tile.get_tileset_index() != MAP_ZONE.EMPTY) {
            update_limits(_position);
        }
    }

    /// Retorna a tile armazenada em uma posição do mapa.
    /// @param {Struct.Vector2} _position A posição da tile no mapa.
    /// @returns {Struct.MapTile} A tile do mapa.
    get_tile = function(_position) {
        var _index = string(_position);

        if (!variable_struct_exists(tiles, _index)) return new MapTile();

        return tiles[$ _index];
    }

    /// Marca como visitada a tile de sala armazenada em uma posição do mapa.
    /// @param {Struct.Vector2} _position A posição da tile no mapa.
    set_room_tile_visited = function(_position) {
        var _tile = get_tile(_position);
        _tile.visited = true;
        update_limits(_position);
    }

    /// Atualiza os limites do mapa com base na posição informada.
    /// @param {Struct.Vector2} _position A posição da tile no mapa.
    update_limits = function(_position) {
        if (limits.left > _position.x) {
            limits.left = _position.x;
        }
        if (limits.right < _position.x) {
            limits.right = _position.x;
        }
        if (limits.top > _position.y) {
            limits.top = _position.y;
        }
        if (limits.bottom < _position.y) {
            limits.bottom = _position.y;
        }
    }
}
