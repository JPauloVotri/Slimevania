viewSurface = -1;
deathSurface = -1;
if (instance_number(oCamera) > 1) {
    instance_destroy();
    exit;
}

gameSize = new Vector2(
    camera_get_view_width(view_camera[0]),
    camera_get_view_height(view_camera[0])
);
target = oPlayer;
goTo = new Vector2(x, y);

x = oPlayer.x - gameSize.x * .5;
y = oPlayer.y - gameSize.y * .5;

application_surface_enable(false);
camera_set_view_size(view_camera[0], gameSize.x + 1, gameSize.y + 1);
display_set_gui_size(gameSize.x, gameSize.y);

hud = new HudManager();

function clear_death_surface() {
    if (surface_exists(deathSurface)) surface_free(deathSurface);
    deathSurface = -1;
}

function snap_to_player() {
    x = clamp(oPlayer.x - gameSize.x * .5, 0, max(0, room_width - gameSize.x));
    y = clamp(oPlayer.y - gameSize.y * .5, 0, max(0, room_height - gameSize.y));
    goTo.rewrite(x, y);
    camera_set_view_size(view_camera[0], gameSize.x + 1, gameSize.y + 1);
    camera_set_view_pos(view_camera[0], floor(x), floor(y));
}

function draw_view(_surface) {
    if (!view_enabled || !view_visible[0] || !surface_exists(_surface)) return;

    var _drawWidth = min(room_width, gameSize.x);
    var _drawX = floor((gameSize.x - _drawWidth) * .5);
    var _sourceX = frac(x);
    if (_drawX > 0) {
        _sourceX = max(0, -floor(x));
        var _previousColor = draw_get_color();
        draw_set_color(c_black);
        draw_rectangle(0, 0, _drawX, gameSize.y, false);
        draw_rectangle(_drawX + _drawWidth, 0, gameSize.x, gameSize.y, false);
        draw_set_color(_previousColor);
    }
    draw_surface_part(_surface, _sourceX, frac(y), _drawWidth, gameSize.y, _drawX, 0);
}
