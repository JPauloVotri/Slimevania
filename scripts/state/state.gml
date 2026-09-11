/// Representa um estado individual dentro de uma máquina de estados.
function State() constructor {
    /** Função vazia usada como padrão para estados que não possuem
     * implementação de criação, atualização ou destruição.
     */
    static NONE = function() {};

    destroy = NONE;
    create = NONE;
    update = NONE;
}
