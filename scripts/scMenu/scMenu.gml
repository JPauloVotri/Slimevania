/// Cria uma instância de menu na tela com as opções e uma função opcional de inicialização.
/// @param {Real} _x Posição X inicial do menu na tela.
/// @param {Real} _y Posição Y inicial do menu na tela.
/// @param {Array<Struct.MenuOption>} _options Lista de opções exibidas no menu.
/// @param {[String|Undefined]} [_description] Texto descritivo opcional do menu.
/// @param {[Function|Undefined]} [_on_create] Callback executado após a criação da instância do menu.
/// @returns {Id.Instance.oMenu} A instância do menu criada.
function menu(_x, _y, _options, _description = undefined, _on_create = undefined) {
    var _menuInstance = instance_create_depth(_x, _y, -999, oMenu);

    /// @self Id.Instance.oMenu
    with (_menuInstance) {
        options = _options;
        description = _description;
        optionsCount = array_length(_options);

        if (!is_undefined(_on_create)) {
            _on_create(self);
        }
    }

    return _menuInstance;
}
