var _color = scenery_particle_color(theme);

gpu_set_blendmode(bm_add);
for (var _i = 0; _i < array_length(particles); _i++) {
    var _p = particles[_i];
    var _twinkle = .55 + .45 * sin(time * .06 + _p.phase * 3);
    draw_sprite_ext(sSceneGlow, 0, _p.x, _p.y, _p.size, _p.size, 0, _color, .55 * _twinkle);
}
gpu_set_blendmode(bm_normal);

// Vinheta escurecendo as bordas da visão.
var _cam = view_camera[0];
draw_sprite_stretched_ext(sSceneVignette, 0,
    camera_get_view_x(_cam), camera_get_view_y(_cam),
    camera_get_view_width(_cam), camera_get_view_height(_cam), c_white, .9);
