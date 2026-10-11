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

        uiRight: inputManager.create_input()
            .add_keyboard_key(vk_right)
            .add_keyboard_key(ord("D"))
            .add_gamepad_button(gp_padr)
            .add_gamepad_left_stick(INPUT_AXIS.RIGHT),

        uiLeft: inputManager.create_input()
            .add_keyboard_key(vk_left)
            .add_keyboard_key(ord("A"))
            .add_gamepad_button(gp_padl)
            .add_gamepad_left_stick(INPUT_AXIS.LEFT),

        uiUp: inputManager.create_input()
            .add_keyboard_key(vk_up)
            .add_keyboard_key(ord("W"))
            .add_gamepad_button(gp_padu)
            .add_gamepad_left_stick(INPUT_AXIS.UP),

        uiDown: inputManager.create_input()
            .add_keyboard_key(vk_down)
            .add_keyboard_key(ord("S"))
            .add_gamepad_button(gp_padd)
            .add_gamepad_left_stick(INPUT_AXIS.DOWN),

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

    return menu(0, 0, [-1, 0], [-1, 0], [4, 4, 1, 4], _options, ftPixelOperator, undefined, true, function(_menu) {
        var _cellSize = new Vector2(16, 9);
        var _margin = _cellSize.copy().scaleRW(1.5).rndRW();
        var _menuHeight = 0;

        /// @self Id.Instance.oMenu
        with (_menu) {
            inputs.previous = INPUT_KEYS.previous;
            inputs.next = INPUT_KEYS.next;

            _menuHeight = heightFull + margin.bottom;
        }

        var _mapSpace = new Vector2(
            view_get_wport(0) - _margin.x * 2,
            view_get_hport(0) - _menuHeight - _margin.y * 2
        );
        var _mapSize = new Vector2(
            _mapSpace.x div _cellSize.x,
            _mapSpace.y div _cellSize.y
        );
        var _mapPosition = new Vector2(
            _margin.x,
            view_get_hport(0) - _margin.y - _mapSize.y * _cellSize.y
        );

        menuMapDraw.set_position(_mapPosition);
        menuMapDraw.set_size(_mapSize.x, _mapSize.y);
    })
    .set_on_draw(function(_menu) {
        draw_set_color(C_MANTLE);

        /// @self Id.Instance.oMenu
        with (_menu) {
            draw_rectangle(0, heightFull + margin.bottom, view_get_wport(0), view_get_hport(0), false);
        }

        menuMapDraw.draw(roomManager.get_current_room_position(), menuMapCenter);

        // TODO: Apenas para testes. Remover depois.
        draw_set_color(c_red);
        draw_rectangle(mouse_x, mouse_y, mouse_x, mouse_y, false);
    })
    .set_option_draw(function(_menu, _option, _x, _y, _isHovered) {
        draw_set_halign(fa_center);

        /// @self Id.Instance.oMenu
        with (_menu) {
            draw_set_color(_isHovered ? colors.hover : colors.text);
            draw_text(_x + optionsSize.x div 2 - optionsBorder.left, _y, _option.label);

            if (_isHovered) {
                draw_rectangle(
                    _x - optionsBorder.left,
                    _y - optionsBorder.top,
                    _x - optionsBorder.right + optionsSize.x - 1,
                    _y - optionsBorder.top + 1,
                    false
                );
            }
        }
    })
    .set_on_destroy(function(_menu) {
        toggle_pause_game();
    });
}
