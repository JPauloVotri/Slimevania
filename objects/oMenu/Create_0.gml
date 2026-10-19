#macro INPUT_KEYS oGame.inputKeys

/// @type {Id.Instance.oMenu}
parent = undefined;

/// @type {Array<Struct.MenuOption>}
options = [];
description = undefined;

// Configuração visual e de layout.
isHorizontal = false;
optionsCount = 0;
optionsSize = new Vector2(0, 0);

margin = {
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
};

padding = {
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
};

optionsBorder = {
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
};

width = 0;
height = 0;
widthFull = 0;
heightFull = 0;

// Estado do menu.
hover = 0;
onFocus = false;
mousePrev = new Vector2(mouse_x, mouse_y);
font = undefined;
mouseOver = false;

colors = {
    background: C_BASE,
    description: C_SUBTEXT0,
    text: C_TEXT,
    hover: C_GREEN,
    optionBg: C_SURFACE0,
    optionBgHover: C_SURFACE1,
};

inputs = {
    confirm: INPUT_KEYS.confirm,
    cancel: INPUT_KEYS.cancel,
    previous: INPUT_KEYS.up,
    next: INPUT_KEYS.down,
    close: INPUT_KEYS.start,
};

/// Callback opcional executado no evento Step.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
on_step = undefined;

/// Callback opcional executado no evento Draw GUI antes do desenho do painel.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu passada ao callback.
on_draw = undefined;

/// Desenha uma opção do menu, destacando o estado de hover e aplicando a cor de fundo.
/// @type {Function|Undefined}
/// @param {Id.Instance.oMenu} _menu Instância do menu que está renderizando a opção.
/// @param {Struct.MenuOption} _option Opção a ser desenhada.
/// @param {Real} _x Posição X da opção no GUI.
/// @param {Real} _y Posição Y da opção no GUI.
/// @param {Boolean} _isHovered Indica se a opção está sob o cursor/seleção atual.
option_draw = function(_menu, _option, _x, _y, _isHovered) {
    draw_set_color(_isHovered ? colors.optionBgHover : colors.optionBg);
    draw_rectangle(
        _x - optionsBorder.left,
        _y - optionsBorder.top,
        _x - optionsBorder.left + optionsSize.x - 1,
        _y - optionsBorder.top + optionsSize.y - 1,
        false
    );

    draw_set_color(_isHovered ? colors.hover : colors.text);
    draw_text(_x, _y, _option.label);
}

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

/// Define a função responsável por desenhar cada opção do menu.
/// @param {Function} _option_draw Função personalizada para desenhar a opção.
/// @returns {Id.Instance.oMenu} Esta instância, para encadear chamadas.
set_option_draw = function(_option_draw) {
    option_draw = _option_draw;
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
