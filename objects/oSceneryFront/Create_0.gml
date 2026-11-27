/// Camada da frente do cenário: partículas flutuando e vinheta nas bordas da tela.
if (instance_number(oSceneryFront) > 1) {
    instance_destroy();
    exit;
}

PARTICLE_COUNT = 34;
theme = SCENE_THEME.CAVERNAS;
particles = [];
time = 0;

/// Espalha as partículas pela sala atual com o comportamento do tema.
function setup_room() {
    theme = scenery_theme_for_room(room);
    particles = [];
    for (var _i = 0; _i < PARTICLE_COUNT; _i++) {
        array_push(particles, new_particle(random(room_width), random(room_height)));
    }
}

/// @returns {Struct}
function new_particle(_x, _y) {
    var _rise = (theme == SCENE_THEME.AGUA_ESTRANHA) ? random_range(.15, .45) : random_range(.02, .12);
    return {
        x: _x,
        y: _y,
        vx: random_range(-.12, .12),
        vy: -_rise,
        size: random_range(.25, .6),
        phase: random(pi * 2),
    };
}

setup_room();
