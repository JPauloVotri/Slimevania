#macro TILE_TINT_UNVISITED #AAAAAA
#macro TILE_TINT_VISITED #FFFFFF

enum MAP_ZONE {
    EMPTY = 1,
    GRAY,
    BLUE,
    RED,
    YELLOW,
    PURPLE,
    GREEN,
}

/// Classe das Tiles do mapa que representam uma sala.
/// @param {Bool} [_visited] Se a sala já foi visitada.
/// @param {Bool} [_hidden] Se a sala é oculta mesmo que o mapa seja revelado.
/// @param {Enum.MAP_ZONE} [_zone] Zona do mapa para coloração e descobrimento.
function MapTile(
    _visited = false,
    _hidden = false,
    _zone = MAP_ZONE.EMPTY
) constructor {
    visited = _visited;
    hidden = _hidden;
    zone = _zone;

    /// Retorna índice do tile na tileset de acordo à zona e ocultação da sala.
    /// @returns {Enum.MAP_ZONE} O índice do tile na tileset.
    get_tileset_index = function() {
        if (hidden && !visited) return MAP_ZONE.EMPTY;

        return zone;
    }

    /// Retorna a cor de tingimento da tile, conforme estado de visita da sala.
    /// @returns {Real} O código da cor de tingimento.
    get_tint = function() {
        if (get_tileset_index() == MAP_ZONE.EMPTY) return TILE_TINT_VISITED;
        if (!visited && !hidden) return TILE_TINT_UNVISITED;

        return TILE_TINT_VISITED;
    }
}
