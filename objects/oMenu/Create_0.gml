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

/// @type {Function|Undefined}
on_step = undefined;

/// @type {Function|Undefined}
on_draw = undefined;

/// @type {Function|Undefined}
on_destroy = undefined;

/// @param {Function} _on_step
/// @returns {Id.Instance.oMenu}
set_on_step = function(_on_step) {
    on_step = _on_step;
    return self;
}

/// @param {Function} _on_draw
/// @returns {Id.Instance.oMenu}
set_on_draw = function(_on_draw) {
    on_draw = _on_draw;
    return self;
}

/// @param {Function} _on_destroy
/// @returns {Id.Instance.oMenu}
set_on_destroy = function(_on_destroy) {
    on_destroy = _on_destroy;
    return self;
}
