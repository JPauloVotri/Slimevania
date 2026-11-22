if (view_enabled && view_visible[0] && surface_exists(viewSurface)) {
    var _drawWidth = min(room_width, gameSize.x);
    var _drawX = floor((gameSize.x - _drawWidth) * 0.5);
    var _sourceX = frac(x);

    if (_drawX > 0) {
        _sourceX = max(0, -floor(x));
        var _previousColor = draw_get_color();
        draw_set_color(c_black);
        draw_rectangle(0, 0, _drawX, gameSize.y, false);
        draw_rectangle(_drawX + _drawWidth, 0, gameSize.x, gameSize.y, false);
        draw_set_color(_previousColor);
    }

    draw_surface_part(
        viewSurface,
        _sourceX,
        frac(y),
        _drawWidth,
        gameSize.y,
        _drawX,
        0
    );
}
