var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam);
var _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

// Fundo distante e silhuetas próximas, com um leve parallax.
var _scale = max(_vw / 320, _vh / 180) * 1.08;
var _bgW = 320 * _scale;
var _bgH = 180 * _scale;
draw_sprite_ext(sSceneBgFar, theme, _vx - (_bgW - _vw) * .5 - _vx * .03, _vy - (_bgH - _vh) * .5 - _vy * .03,
    _scale, _scale, 0, c_white, 1);
draw_rays();
draw_sprite_ext(sSceneBgMid, theme, _vx - (_bgW - _vw) * .5 - _vx * .08, _vy - (_bgH - _vh) * .5 - _vy * .08,
    _scale, _scale, 0, c_white, 1);

// Terreno em cache (a surface pode sumir, por exemplo ao minimizar a janela).
if (terrainDirty || !surface_exists(terrain)) build_terrain();
draw_surface(terrain, 0, 0);
draw_glows();
