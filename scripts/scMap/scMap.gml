/// Estrutura que armazena as tiles do mapa por posição.
function Map() constructor {
    tiles = {};

    /// Adiciona uma tile ao mapa.
    /// @param {Struct.Vector2} _position A posição da tile no mapa.
    /// @param {Struct.MapTile} _tile A tile do mapa.
    add_tile = function(_position, _tile) {
        var _index = string(_position)
        tiles[$ _index] = _tile;
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
    }
}
