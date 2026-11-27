/// Desenha o fundo e o terreno decorado da sala. Só visual: as colisões continuam
/// nos blocos originais, que ficam invisíveis.
if (instance_number(oScenery) > 1) {
    instance_destroy();
    exit;
}

TILE = 16;
theme = SCENE_THEME.CAVERNAS;
terrain = -1;
terrainDirty = true;
blockCount = -1;
glows = [];
rays = [];
time = 0;

/// Prepara a sala atual: tema, profundidade, blocos invisíveis e raios de luz.
function setup_room() {
    theme = scenery_theme_for_room(room);
    terrainDirty = true;
    blockCount = -1;

    // Fica logo à frente da camada de fundo e atrás de todas as instâncias.
    var _background = layer_get_id("Background");
    depth = (_background != -1) ? layer_get_depth(_background) - 1 : 1000;

    with (oBlock) {
        if (object_index != oWaterSpring && object_index != oStrangeWaterSpring) visible = false;
    }
    with (oOneWayBlock) visible = false;

    // As nascentes continuam com o próprio sprite animado, só tingido com a cor da área.
    var _tint = scenery_glow_color(theme);
    with (oWaterSpring) image_blend = merge_color(c_white, _tint, .45);
    with (oStrangeWaterSpring) image_blend = merge_color(c_white, _tint, .45);

    // Raios de luz em posições fixas por sala.
    rays = [];
    random_set_seed(scenery_room_seed() + 31);
    var _count = 2 + irandom(2);
    for (var _i = 0; _i < _count; _i++) {
        array_push(rays, {
            x: random_range(.1, .9) * room_width,
            width: random_range(18, 46),
            slant: random_range(40, 110) * choose(-1, 1),
            phase: random(pi * 2),
        });
    }
    randomize();
}

/// Retorna se há algum bloco cobrindo o retângulo (fora o próprio bloco que chama).
function scenery_solid(_x1, _y1, _x2, _y2) {
    return collision_rectangle(_x1, _y1, _x2, _y2, oBlock, true, true) != noone
        || collision_rectangle(_x1, _y1, _x2, _y2, oOneWayBlock, false, true) != noone;
}

/// Monta numa surface o terreno da sala inteira (texturas, musgo, bordas, decoração).
function build_terrain() {
    if (!surface_exists(terrain)) terrain = surface_create(room_width, room_height);
    surface_set_target(terrain);
    draw_clear_alpha(c_black, 0);

    var _theme = theme;
    var _tile = TILE;
    var _glows = [];
    random_set_seed(scenery_room_seed() * 3 + 17);

    // 1. Preenchimento de pedra.
    with (oBlock) {
        if (object_index == oWaterSpring || object_index == oStrangeWaterSpring) continue;
        if (object_index == oHalfBlock) {
            draw_sprite_ext(sSceneSlope, _theme, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
            continue;
        }
        var _fill = (object_index == oCrackedBlock) ? sSceneRockAlt : sSceneRock;
        scenery_tile_area(_fill, _theme, 0, 0, bbox_left, bbox_top, bbox_right, bbox_bottom);
    }

    // 2. Bordas expostas: musgo em cima, estalactites embaixo, contorno nas laterais.
    with (oBlock) {
        if (object_index == oWaterSpring || object_index == oStrangeWaterSpring || object_index == oHalfBlock) continue;
        var _x1 = bbox_left, _y1 = bbox_top, _x2 = bbox_right, _y2 = bbox_bottom;

        for (var _cx = _x1; _cx <= _x2; _cx += _tile) {
            var _w = min(_tile, _x2 - _cx + 1);
            var _cr = _cx + _w - 1;

            if (_y1 > 0 && !other.scenery_solid(_cx, _y1 - 2, _cr, _y1 - 1)) {
                draw_sprite_part(sSceneTop, _theme, 0, 0, _w, 10, _cx, _y1 - 3);

                // Decoração só onde cabe um tile inteiro livre acima.
                if (_w == _tile && random(1) < .32 && !other.scenery_solid(_cx, _y1 - 16, _cr, _y1 - 1)) {
                    var _kind = choose(0, 0, 1, 1, 2, 3, 4, 4, 5, 6, 7);
                    draw_sprite(sSceneDecor, _theme * 8 + _kind, _cx, _y1 - 15);
                    if (_kind == 4 || _kind == 5) array_push(_glows, [_cx + 8, _y1 - 7, random(pi * 2)]);
                }
            }

            if (_y2 < room_height - 1 && !other.scenery_solid(_cx, _y2 + 1, _cr, _y2 + 2)) {
                draw_sprite_part(sSceneDrips, _theme, 0, 0, _w, 8, _cx, _y2 + 1);
            }
        }

        for (var _cy = _y1; _cy <= _y2; _cy += _tile) {
            var _h = min(_tile, _y2 - _cy + 1);
            var _cb = _cy + _h - 1;
            if (_x1 > 0 && !other.scenery_solid(_x1 - 2, _cy, _x1 - 1, _cb)) {
                draw_set_alpha(.6);
                draw_set_color(c_black);
                draw_line(_x1, _cy, _x1, _cb + 1);
                draw_set_alpha(.12);
                draw_set_color(c_white);
                draw_line(_x1 + 1, _cy, _x1 + 1, _cb + 1);
            }
            if (_x2 < room_width - 1 && !other.scenery_solid(_x2 + 1, _cy, _x2 + 2, _cb)) {
                draw_set_alpha(.6);
                draw_set_color(c_black);
                draw_line(_x2, _cy, _x2, _cb + 1);
                draw_set_alpha(.25);
                draw_line(_x2 - 1, _cy, _x2 - 1, _cb + 1);
            }
        }
        draw_set_alpha(1);
        draw_set_color(c_white);
    }

    // 3. Pistas visuais das mecânicas: trepadeiras no escalável e rachaduras no quebrável.
    with (oRoughcastBlock) {
        scenery_tile_area(sSceneVines, _theme, 0, 0, bbox_left, bbox_top, bbox_right, bbox_bottom);
    }
    with (oCrackedBlock) {
        scenery_tile_area(sSceneCrack, 0, bbox_left, bbox_top, bbox_left, bbox_top, bbox_right, bbox_bottom);
        draw_set_alpha(.7);
        draw_set_color(c_black);
        draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }

    // 4. Plataformas atravessáveis viram pranchas.
    with (oOneWayBlock) {
        scenery_tile_area(sScenePlatform, _theme, bbox_left, bbox_top, bbox_left, bbox_top, bbox_right, bbox_bottom);
    }

    surface_reset_target();
    glows = _glows;
    randomize();
    terrainDirty = false;
}

/// Raios de luz suaves vindos do teto (mistura aditiva).
function draw_rays() {
    var _strength = scenery_ray_strength(theme);
    if (_strength <= 0) return;

    var _color = scenery_glow_color(theme);
    gpu_set_blendmode(bm_add);
    for (var _i = 0; _i < array_length(rays); _i++) {
        var _ray = rays[_i];
        var _alpha = _strength * (.75 + .25 * sin(time * .02 + _ray.phase));
        var _bottom = room_height;
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_ray.x, 0, _color, _alpha);
        draw_vertex_color(_ray.x + _ray.width, 0, _color, _alpha);
        draw_vertex_color(_ray.x + _ray.slant, _bottom, _color, 0);
        draw_vertex_color(_ray.x + _ray.slant + _ray.width * 2.2, _bottom, _color, 0);
        draw_primitive_end();
    }
    gpu_set_blendmode(bm_normal);
}

/// Halos pulsando em volta dos cogumelos e cristais.
function draw_glows() {
    var _color = scenery_glow_color(theme);
    gpu_set_blendmode(bm_add);
    for (var _i = 0; _i < array_length(glows); _i++) {
        var _g = glows[_i];
        var _pulse = .5 + .5 * sin(time * .05 + _g[2]);
        draw_sprite_ext(sSceneGlow, 0, _g[0], _g[1], 1.6 + _pulse * .5, 1.6 + _pulse * .5, 0, _color, .25 + _pulse * .2);
    }
    gpu_set_blendmode(bm_normal);
}

setup_room();
