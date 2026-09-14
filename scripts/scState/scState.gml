/** Representa um estado individual dentro de uma máquina de estados.
 * @param {String} _name Nome identificador do estado.
 */
function State(_name) constructor {
    name = _name;

    /// @type {Function}
    create = undefined;
    /// @type {Function}
    update = undefined;
    /// @type {Function}
    destroy = undefined;

    /** Define a função executada ao entrar no estado.
     * @param {Function} _create_function Função de criação do estado.
     * @returns {Struct.State} A própria instância do estado.
     */
    static set_create = function(_create_function) {
        create = _create_function;
        return self;
    }

    /** Define a função executada a cada frame enquanto o estado estiver ativo.
     * @param {Function} _update_function Função de atualização do estado.
     * @returns {Struct.State} A própria instância do estado.
     */
    static set_update = function(_update_function) {
        update = _update_function;
        return self;
    }

    /** Define a função executada ao sair do estado.
     * @param {Function} _destroy_function Função de destruição do estado.
     * @returns {Struct.State} A própria instância do estado.
     */
    static set_destroy = function(_destroy_function) {
        destroy = _destroy_function;
        return self;
    }
}
