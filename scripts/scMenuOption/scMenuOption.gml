/// Representa uma opção de menu com texto e ação opcional ao ser selecionada.
/// @param {String} _label Texto exibido para a opção no menu.
/// @param {[Function|Undefined]} [_action] Função executada ao selecionar esta opção, se houver.
function MenuOption(_label, _action = undefined) constructor {
    label = _label;
    action = _action;
}
