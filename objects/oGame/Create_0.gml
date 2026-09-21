if (instance_number(oGame) > 1) {
    instance_destroy();
    return;
}

var _minimapPosition = new Vector2(8, 8);

roomManager = new RoomManager();
miniMapDraw = new MapDraw(roomManager.map, _minimapPosition, 5, 5);

/// Retorna a direção de saída do player da sala.
/// @param {Real} _x Posição X do player.
/// @param {Real} _y Posição Y do player.
/// @returns {Struct.Vector2}
function get_transition_direction(_x, _y) {
    var _out_left   = _x < 0;
    var _out_right  = _x >= room_width;
    var _out_top    = _y < 0;
    var _out_bottom = _y >= room_height;

    return new Vector2(_out_right - _out_left, _out_bottom - _out_top);
}
