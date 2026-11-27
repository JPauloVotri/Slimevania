/// Temas visuais do cenário. A ordem é a mesma dos quadros dos sprites sScene*.
enum SCENE_THEME { NASCENTE, CAVERNAS, SOMBRA, AGUA_ESTRANHA, SANTUARIO }

/// Retorna o tema visual da sala (as mesmas áreas usadas pelas músicas).
/// @param {Asset.GMRoom} _room
/// @returns {Real}
function scenery_theme_for_room(_room) {
    switch (room_get_name(_room)) {
        case "room_0_0":   return SCENE_THEME.NASCENTE;
        case "room_0_n1":  return SCENE_THEME.SOMBRA;
        case "room_1_n1":
        case "room_2_n1":  return SCENE_THEME.AGUA_ESTRANHA;
        case "room_n1_n1": return SCENE_THEME.SANTUARIO;
        default:           return SCENE_THEME.CAVERNAS;
    }
}

/// Cor dos brilhos (cogumelos, cristais, raios de luz) de cada tema.
/// @param {Real} _theme
/// @returns {Constant.Color}
function scenery_glow_color(_theme) {
    static _colors = [
        make_color_rgb(143, 240, 255),
        make_color_rgb(255, 179, 92),
        make_color_rgb(199, 125, 255),
        make_color_rgb(166, 255, 92),
        make_color_rgb(255, 210, 122),
    ];
    return _colors[_theme];
}

/// Cor das partículas flutuantes de cada tema.
/// @param {Real} _theme
/// @returns {Constant.Color}
function scenery_particle_color(_theme) {
    static _colors = [
        make_color_rgb(170, 245, 255),
        make_color_rgb(210, 190, 255),
        make_color_rgb(180, 120, 255),
        make_color_rgb(190, 255, 110),
        make_color_rgb(255, 225, 140),
    ];
    return _colors[_theme];
}

/// Intensidade dos raios de luz vindos do teto (0 = sem raios).
/// @param {Real} _theme
/// @returns {Real}
function scenery_ray_strength(_theme) {
    static _strength = [.11, .04, 0, .035, .14];
    return _strength[_theme];
}

/// Desenha uma área de água translúcida com superfície ondulando e brilho.
/// Chamado no Draw de oWater e oStrangeWater (só visual).
/// @param {Constant.Color} _top Cor perto da superfície.
/// @param {Constant.Color} _bottom Cor do fundo.
/// @param {Constant.Color} _foam Cor da linha da superfície.
/// @param {Bool} _bubbles Se sobem bolhas (água estranha).
function draw_water_body(_top, _bottom, _foam, _bubbles) {
    // Pedaços girados (filetes) usam o próprio sprite, só mais suave.
    if (image_angle != 0) {
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _top, .75);
        return;
    }

    var _x1 = bbox_left, _y1 = bbox_top, _x2 = bbox_right, _y2 = bbox_bottom;
    var _t = current_time / 1000;

    draw_set_alpha(.62);
    draw_rectangle_color(_x1, _y1, _x2, _y2, _top, _top, _bottom, _bottom, false);

    // Linha da superfície ondulando.
    draw_set_alpha(.95);
    draw_set_color(_foam);
    for (var _x = _x1; _x <= _x2; _x += 2) {
        var _offset = round(sin(_x * .22 + _t * 3) * .8);
        draw_rectangle(_x, _y1 + _offset, min(_x + 1, _x2), _y1 + _offset, false);
    }

    // Reflexos que vão e voltam.
    draw_set_alpha(.35 + .2 * sin(_t * 2));
    var _width = _x2 - _x1;
    for (var _i = 0; _i < max(1, _width div 40); _i++) {
        var _rx = _x1 + ((_i * 53 + _t * 12) mod max(1, _width - 6));
        var _ry = _y1 + 3 + (_i mod 3) * 3;
        if (_ry < _y2) draw_line(_rx, _ry, _rx + 4, _ry);
    }

    if (_bubbles) {
        draw_set_alpha(.8);
        var _height = max(1, _y2 - _y1);
        for (var _b = 0; _b < max(1, _width div 24); _b++) {
            var _bx = _x1 + ((_b * 37) mod max(1, _width));
            var _by = _y2 - ((_t * (8 + (_b mod 4) * 3) + _b * 13) mod _height);
            draw_circle(_bx + sin(_t * 3 + _b) * 1.5, _by, 1, true);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// Semente estável por sala, para a decoração sair sempre igual na mesma sala.
/// @returns {Real}
function scenery_room_seed() {
    var _name = room_get_name(room);
    var _hash = 7;
    for (var _i = 1; _i <= string_length(_name); _i++) {
        _hash = (_hash * 31 + ord(string_char_at(_name, _i))) mod 1000003;
    }
    return _hash;
}

/// Preenche um retângulo repetindo o sprite, alinhado à grade que começa em (_xo, _yo).
/// @param {Asset.GMSprite} _sprite
/// @param {Real} _subimg
/// @param {Real} _xo Origem X da grade de tiles.
/// @param {Real} _yo Origem Y da grade de tiles.
/// @param {Real} _x1 Esquerda (inclusiva).
/// @param {Real} _y1 Topo (inclusivo).
/// @param {Real} _x2 Direita (inclusiva).
/// @param {Real} _y2 Base (inclusiva).
function scenery_tile_area(_sprite, _subimg, _xo, _yo, _x1, _y1, _x2, _y2) {
    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    _x1 = floor(_x1); _y1 = floor(_y1); _x2 = floor(_x2); _y2 = floor(_y2);

    var _startX = _xo + floor((_x1 - _xo) / _w) * _w;
    var _startY = _yo + floor((_y1 - _yo) / _h) * _h;

    for (var _ty = _startY; _ty <= _y2; _ty += _h) {
        var _top = max(_ty, _y1);
        var _bottom = min(_ty + _h - 1, _y2);
        for (var _tx = _startX; _tx <= _x2; _tx += _w) {
            var _left = max(_tx, _x1);
            var _right = min(_tx + _w - 1, _x2);
            draw_sprite_part(_sprite, _subimg, _left - _tx, _top - _ty,
                _right - _left + 1, _bottom - _top + 1, _left, _top);
        }
    }
}
