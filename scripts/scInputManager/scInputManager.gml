/// Gerencia as entradas configuradas e atualiza seus estados.
/// @param {Real} _gamepad Índice do controle usado pelas entradas.
/// @param {Real} _deadzone Limite mínimo de ativação dos analógicos.
function InputManager(_gamepad = 0, _deadzone = .4) constructor {
    __inputs = [];
    gamepad = _gamepad;
    deadzone = _deadzone;
    buffer = 5;

    /// Atualiza todas as entradas registradas; deve ser chamada a cada frame.
    run = function() {
        var _len = array_length(__inputs);

        for (var _i = 0; _i < _len; _i++) {
            __inputs[_i].__update();
        }
    }

    /// Cria e registra uma entrada vinculada a este gerenciador.
    /// @returns {Struct.Input} A nova entrada.
    create_input = function() {
        var _input = new Input(self);
        array_push(__inputs, _input);
        return _input;
    }
}
