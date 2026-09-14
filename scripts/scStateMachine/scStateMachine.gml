/** Representa uma máquina de estados que gerencia o estado atual, o tempo
 * decorrido naquele estado e a troca entre estados.
 */
function StateMachine() constructor {
    /// @type {Struct.State}
    state = undefined;
    /// @type {Struct<Struct.State>}
    states = {};
    time = 0;

    /** Troca o estado atual da máquina de estados.
     * @param {String} _name Novo estado a ser ativado.
     */
    static change_state = function(_name) {
        if (is_method(state.destroy)) {
            state.destroy();
        }

        if (is_undefined(states[$ _name])) {
            show_debug_message($"Tentando mudar para um State não existente!");
            return;
        }

        state = states[$ _name];
        time = 0;

        if (is_method(state.create)) {
            state.create();
        }
    }

    /** Adiciona um estado à máquina de estados.
     * @param {Struct.State} _state Estado a ser registrado na máquina.
     * @returns {Struct.StateMachine} A própria instância da máquina de estados.
     */
    static add_state = function(_state) {
        if (!is_undefined(states[$ _state.name])) {
            show_debug_message($"Um State com o name {_state.name} já existe " +
                "na StateMachine!");
        }
        states[$ _state.name] = _state;

        if (is_undefined(state)) {
            state = _state;
        }

        return self;
    }

    /// Atualiza o estado atual da máquina e incrementa o contador de tempo.
    static update = function() {
        if (!is_instanceof(state, State)) return;
        if (!is_method(state.update)) return;

        state.update();
        time++;
    }
}
