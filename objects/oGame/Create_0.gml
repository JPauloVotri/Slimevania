if (instance_number(oGame) > 1) {
    instance_destroy();
    return;
}

var _minimapPosition = new Vector2(8, 8);
var _menuMapPosition = new Vector2(24, 18);

roomManager = new RoomManager();
miniMapDraw = new MapDraw(roomManager.map, _minimapPosition, 5, 5);
menuMapDraw = new MapDraw(roomManager.map, _menuMapPosition, 29, 29);
menuMapCenter = new Vector2(0, 0);
isPaused = false;

#region Inputs
    gamepads = []; // Variável que será usada para listagem de controles.
    inputManager = new InputManager();

    inputKeys = {
        right: inputManager.create_input()
            .add_keyboard_key(vk_right)
            .add_keyboard_key(ord("D"))
            .add_gamepad_button(gp_padr)
            .add_gamepad_left_stick(INPUT_AXIS.RIGHT),

        left: inputManager.create_input()
            .add_keyboard_key(vk_left)
            .add_keyboard_key(ord("A"))
            .add_gamepad_button(gp_padl)
            .add_gamepad_left_stick(INPUT_AXIS.LEFT),

        up: inputManager.create_input()
            .add_keyboard_key(vk_up)
            .add_keyboard_key(ord("W"))
            .add_gamepad_button(gp_padu)
            .add_gamepad_left_stick(INPUT_AXIS.UP),

        down: inputManager.create_input()
            .add_keyboard_key(vk_down)
            .add_keyboard_key(ord("S"))
            .add_gamepad_button(gp_padd)
            .add_gamepad_left_stick(INPUT_AXIS.DOWN),

        pad1: inputManager.create_input()
            .add_keyboard_key(vk_space)
            .add_gamepad_button(gp_face1),

        pad3: inputManager.create_input()
            .add_keyboard_key(vk_shift)
            .add_gamepad_button(gp_face3),

        start: inputManager.create_input()
            .add_keyboard_key(vk_escape)
            .add_gamepad_button(gp_start),
    }
#endregion

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
