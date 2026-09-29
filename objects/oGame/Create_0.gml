if (instance_number(oGame) > 1) {
    instance_destroy();
    return;
}

var _minimapPosition = new Vector2(8, 8);
var _menuMapPosition = new Vector2(16, 36);
var _menuMapSize = new Vector2(
    view_get_wport(0) div 16 - 2,
    (view_get_hport(0) - 27) div 9 - 2
);

roomManager = new RoomManager();
miniMapDraw = new MapDraw(roomManager.map, _minimapPosition, 5, 5);
menuMapDraw = new MapDraw(roomManager.map, _menuMapPosition, _menuMapSize.x, _menuMapSize.y);
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

        next: inputManager.create_input()
            .add_keyboard_key(vk_pagedown)
            .add_keyboard_key(ord("E"))
            .add_gamepad_button(gp_shoulderr),

        previous: inputManager.create_input()
            .add_keyboard_key(vk_pageup)
            .add_keyboard_key(ord("Q"))
            .add_gamepad_button(gp_shoulderl),

        start: inputManager.create_input()
            .add_keyboard_key(vk_escape)
            .add_gamepad_button(gp_start),

        confirm: inputManager.create_input()
            .add_keyboard_key(vk_enter)
            .add_gamepad_button(gp_face1),

        cancel: inputManager.create_input()
            .add_gamepad_button(gp_face2),
    };
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

/// Alterna o estado de pausa do jogo.
function toggle_pause_game() {
    isPaused = !isPaused;

    if (isPaused) {
        instance_deactivate_all(true);
        audio_pause_all();
        open_pause_menu();
        menuMapCenter.rewriteRW(roomManager.get_current_room_position());
    } else {
        instance_activate_all();
        audio_resume_all();
    }
}

/// Cria e abre o menu de pausa com as opções disponíveis para o jogador.
/// @returns {Id.Instance.oMenu} A instância do menu de pausa aberta.
function open_pause_menu() {
    var _options = [
        new MenuOption("Continuar", function(_menuInstance) {
            instance_destroy(_menuInstance);
        }),
        new MenuOption("Salvar"),
        new MenuOption("Carregar"),
        new MenuOption("Opções"),
        new MenuOption("Sair", function() {
            game_end();
        }),
    ];

    return menu(0, 0, _options, undefined, function(_menu) {
            /// @self Id.Instance.oMenu
            with (_menu) {
                margin = 4;
                height = 18;
                width = view_get_wport(0) - x * 2;
                heightFull = height + margin * 2;

                draw_set_font(ftPixelOperator);
            }
        }).set_on_step(function(_menu) {
            /// @self Id.Instance.oMenu
            with (_menu) {
                var _optionWidth = view_get_wport(0) div (optionsCount + 2);
                var _optionsLeft = x + _optionWidth;
                var _optionsRight = x + width - _optionWidth;

                if (point_in_rectangle(mouse_x, mouse_y, _optionsLeft, y, _optionsRight, y + heightFull)) {
                    mouseOver = true;

                    if (mousePrev.x != mouse_x || mousePrev.y != mouse_y) {
                        var _mouseHover = (mouse_x - _optionsLeft) div _optionWidth;
                        hover = clamp(_mouseHover, 0, optionsCount - 1);
                    }
                }

                if (inputs.cancel.check_pressed() || inputs.close.check_pressed()) {
                    instance_destroy();
                    return;
                }

                hover += inputs.next.check_stutter(20, 10) - inputs.previous.check_stutter(20, 10);
                hover = (hover + optionsCount) % optionsCount;

                if ((mouse_check_button_pressed(mb_left) && mouseOver) || inputs.confirm.check_pressed()) {
                    var _func = options[hover].action;
                    if (!is_undefined(_func)) _func(self);
                }
            }
        })
        .set_on_draw(function(_menu) {
            /// @self Id.Instance.oMenu
            with (_menu) {
                var _optionWidth = view_get_wport(0) div (optionsCount + 2);
                var _center = x + _optionWidth + _optionWidth div 2;
                var _middle = y + heightFull div 2;

                draw_set_font(ftPixelOperator);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);

                draw_set_color(c_black);
                draw_rectangle(x, y, x + width, y + heightFull, false);

                draw_set_color(c_white);
                draw_text(x + _optionWidth div 2, _middle, "<");

                for (var _i = 0; _i < optionsCount; _i++) {
                    var _label = options[_i].label;
                    var _isHovered = hover == _i;

                    draw_set_color(_isHovered ? c_yellow : c_white);
                    draw_text(_center, _middle, _label);

                    _center += _optionWidth;
                }

                draw_set_color(c_white);
                draw_text(_center, _middle, ">");
            }

            menuMapDraw.draw(roomManager.get_current_room_position(), menuMapCenter);
        })
        .set_on_destroy(function(_menu) {
            toggle_pause_game();
        });
}
