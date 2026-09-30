#macro INPUT_KEYS oGame.inputKeys

/// @type {Id.Instance.oMenu}
parent = undefined;
/// @type {Array<Struct.MenuOption>}
options = [];
description = undefined;
optionsCount = 0;
hovermarker = "";
margin = 0;
width = 0;
height = 0;
hover = 0;
onFocus = false;
mousePrev = new Vector2(mouse_x, mouse_y);

inputs = {
    confirm: INPUT_KEYS.confirm,
    cancel: INPUT_KEYS.cancel,
    previous: INPUT_KEYS.previous,
    next: INPUT_KEYS.next,
    close: INPUT_KEYS.start,
}

/// Callback opcional executado no evento Step.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
on_step = undefined;

/// Callback opcional executado no evento Draw GUI antes do desenho do painel.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
on_draw = undefined;

/// Callback opcional executado no evento Draw GUI para desenhar o painel.
/// Tem precedência sobre `default_panel_draw`.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
panel_draw = undefined;

/// Callback alternativo de desenho do painel, executado no Draw GUI quando `panel_draw` estiver indefinida.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
default_panel_draw = undefined;

/// Callback opcional executado no evento Destroy.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
on_destroy = undefined;

/// Define a função executada no evento Step do menu.
/// @param {Function} _on_step Função executada no Step.
/// @returns {Id.Instance.oMenu} Esta instância, para encadear chamadas.
set_on_step = function(_on_step) {
    on_step = _on_step;
    return self;
}

/// Define a função executada no evento Draw GUI, antes do desenho do painel.
/// @param {Function} _on_draw Função executada no Draw GUI.
/// @returns {Id.Instance.oMenu} Esta instância, para encadear chamadas.
set_on_draw = function(_on_draw) {
    on_draw = _on_draw;
    return self;
}

/// Define a função chamada no Draw GUI, após `on_draw`, para desenhar o painel.
/// Na primeira chamada, também define a função padrão usada quando `panel_draw` estiver indefinida.
/// @param {Function} _panel_draw Função executada no Draw GUI para desenhar o painel.
/// @returns {Id.Instance.oMenu} Esta instância, para encadear chamadas.
set_panel_draw = function(_panel_draw) {
    panel_draw = _panel_draw;

    if (is_undefined(default_panel_draw)) {
        default_panel_draw = _panel_draw;
    }

    return self;
}

/// Define a função executada no evento Destroy do menu.
/// @param {Function} _on_destroy Função executada no Destroy.
/// @returns {Id.Instance.oMenu} Esta instância, para encadear chamadas.
set_on_destroy = function(_on_destroy) {
    on_destroy = _on_destroy;
    return self;
}
