/** Representa uma máquina de estados que gerencia o estado atual, o tempo
 * decorrido naquele estado e a troca entre estados.
 */
function StateMachine() constructor {
    static NULL_STATE = new State();

    state = NULL_STATE;
    time = 0;

    /** Troca o estado atual da máquina de estados.
     * @param {Struct.State} [_state] Novo estado a ser ativado.
     */
    swap = function(_state = NULL_STATE) {
        state.destroy();

        state = _state;
        time = 0;

        state.create();
    }

    /// Atualiza o estado atual da máquina e incrementa o contador de tempo.
    run = function() {
        state.update();
        time++;
    }
}
