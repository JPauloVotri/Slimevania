var _pos = new Vector2(x + padding.left + optionsBorder.left, y + padding.top + optionsBorder.top);

if (!is_undefined(font)) {
    draw_set_font(font);
}

draw_set_color(colors.background);
draw_rectangle(
    x - margin.left,
    y - margin.top,
    x + widthFull + margin.right - 1,
    y + heightFull + margin.bottom - 1,
    false
);

if (!is_undefined(description)) {
    draw_set_color(colors.description);
    draw_text(_pos.x, _pos.y, description);

    _pos.y += optionsSize.y;
}

for (var _i = 0; _i < optionsCount; _i += 1) {
    var _isHovered = hover == _i;

    option_draw(self, options[_i], _pos.x, _pos.y, _isHovered);

    if (isHorizontal) {
        _pos.x += optionsSize.x;
    } else {
        _pos.y += optionsSize.y;
    }
}

if (!is_undefined(on_draw)) {
    on_draw(self);
}

if (!is_undefined(panel_draw)) {
    panel_draw(self);
} else if (!is_undefined(default_panel_draw)) {
    default_panel_draw(self);
}

draw_set_font(-1);
