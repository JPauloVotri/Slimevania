/// Direções dos analógicos do controle.
enum INPUT_AXIS {
    RIGHT,
    UP,
    LEFT,
    DOWN,
}

/// Agrupa fontes de teclado e controle e acompanha o estado temporal da entrada.
/// @param {Struct.InputManager} _manager Gerenciador da entrada.
function Input(_manager) constructor {
    __manager = _manager;
    __time = 0;
    __keys = [];

    /// Avalia as fontes registradas e atualiza o tempo pressionado ou o buffer de liberação.
    __update = function() {
        var _active = false;
        var _len = array_length(__keys);

        for (var _i = 0; _i < _len; _i++) {
            if (__keys[_i].check()) {
                _active = true;
                break;
            }
        }

        if (_active) {
            __time++;
            return;
        }

        if (__time > 0) {
            __time = -__manager.buffer;
            return;
        }

        __time = min(__time + 1, 0);
    }

    /// Registra uma tecla; pressioná-la ativa esta entrada.
    /// @param {Real} _key Tecla a verificar.
    /// @returns {Struct.Input} Esta instância.
    add_keyboard_key = function(_key) {
        var _keyStruct = {
            button: _key,
            check: function() {
                return keyboard_check(button);
            }
        };

        array_push(__keys, _keyStruct);
        return self;
    }

    /// Registra um botão do controle ativo como fonte da entrada.
    /// @param {Real} _button Botão a verificar.
    /// @returns {Struct.Input} Esta instância.
    add_gamepad_button = function(_button) {
        var _keyStruct = {
            creator: other,
            button: _button,
            check: function() {
                return gamepad_button_check(creator.__manager.gamepad, button);
            }
        };

        array_push(__keys, _keyStruct);
        return self;
    }

    /// Registra uma direção do analógico esquerdo, respeitando a zona morta configurada.
    /// @param {Enum.INPUT_AXIS} _direction Direção em INPUT_AXIS.
    /// @returns {Struct.Input} Esta instância.
    add_gamepad_left_stick = function(_direction) {
        var _keyStruct = {
            creator: other,
            axis: _direction == INPUT_AXIS.RIGHT || _direction == INPUT_AXIS.LEFT ? gp_axislh : gp_axislv,
            dir: _direction == INPUT_AXIS.RIGHT || _direction == INPUT_AXIS.DOWN ? 1 : -1,
            check: function() {
                return gamepad_axis_value(creator.__manager.gamepad, axis) * dir >= creator.__manager.deadzone;
            }
        };

        array_push(__keys, _keyStruct);
        return self;
    }

    /// Registra uma direção do analógico direito, respeitando a zona morta configurada.
    /// @param {Enum.INPUT_AXIS} _direction Direção em INPUT_AXIS.
    /// @returns {Struct.Input} Esta instância.
    add_gamepad_right_stick = function(_direction) {
        var _keyStruct = {
            creator: other,
            axis: _direction == INPUT_AXIS.RIGHT || _direction == INPUT_AXIS.LEFT ? gp_axisrh : gp_axisrv,
            dir: _direction == INPUT_AXIS.RIGHT || _direction == INPUT_AXIS.DOWN ? 1 : -1,
            check: function() {
                return gamepad_axis_value(creator.__manager.gamepad, axis) * dir >= creator.__manager.deadzone;
            }
        };

        array_push(__keys, _keyStruct);
        return self;
    }

    /// Verifica se a entrada está pressionada há pelo menos um frame.
    /// @returns {Bool} `true` enquanto pressionada; caso contrário, `false`.
    check = function() {
        return __time > 0;
    }

    /// Detecta o início do pressionamento ou, com buffer, os primeiros frames pressionados.
    /// @param {Bool} _buffered Inclui a janela de buffer configurada.
    /// @returns {Bool} `true` no início ou dentro da janela; caso contrário, `false`.
    check_pressed = function(_buffered = false) {
        if (_buffered) return __time > 0 && __time <= __manager.buffer;
        return __time == 1;
    }

    /// Detecta a liberação ou, com buffer, mantém a detecção durante o buffer.
    /// @param {Bool} _buffered Inclui a janela de buffer de liberação.
    /// @returns {Bool} `true` na liberação ou durante o buffer; caso contrário, `false`.
    check_released = function(_buffered = false) {
        if (_buffered) return __time < 0;
        return __time == -__manager.buffer;
    }

    /// Sinaliza o pressionamento inicial e repetições após o atraso e a cada intervalo.
    /// @param {Real} _initialDelay Frames até iniciar as repetições.
    /// @param {Real} _interval Frames entre repetições.
    /// @returns {Bool} `true` no pressionamento inicial ou em um frame de repetição.
    check_stutter = function(_initialDelay, _interval) {
        if (__time == 1) return true;

        return __time - _initialDelay > 0 && (__time - _initialDelay) % _interval == 0;
    }

    /// Força o estado para pressionado, como se a entrada estivesse ativa.
    fully_press = function() {
        __time = __manager.buffer + 1;
    }

    /// Força o estado para liberado e remove qualquer tempo de buffer.
    fully_release = function() {
        __time = 0;
    }
}
