/// Toca um efeito sonoro com uma leve variação de tom para não soar repetitivo.
/// @param {Asset.GMSound} _sound Som a tocar.
/// @param {Real} [_gain] Volume (0..1).
/// @param {Real} [_pitchVariation] Variação máxima do tom, para cima ou para baixo.
/// @param {Real} [_priority] Prioridade do som.
/// @returns {Id.Sound}
function sfx(_sound, _gain = 1, _pitchVariation = .05, _priority = 1) {
    var _pitch = 1 + random_range(-_pitchVariation, _pitchVariation);
    return audio_play_sound(_sound, _priority, false, _gain, 0, _pitch);
}

/// Toca o som só se a instância estiver perto da câmera, evitando ruído de fora da tela.
/// @param {Asset.GMSound} _sound Som a tocar.
/// @param {Real} _x Posição X da origem do som.
/// @param {Real} _y Posição Y da origem do som.
/// @param {Real} [_gain] Volume (0..1).
/// @param {Real} [_pitchVariation] Variação máxima do tom.
function sfx_at(_sound, _x, _y, _gain = 1, _pitchVariation = .05) {
    var _cam = view_camera[0];
    var _margin = 32;
    var _left = camera_get_view_x(_cam) - _margin;
    var _top = camera_get_view_y(_cam) - _margin;
    var _right = _left + camera_get_view_width(_cam) + _margin * 2;
    var _bottom = _top + camera_get_view_height(_cam) + _margin * 2;

    if (!point_in_rectangle(_x, _y, _left, _top, _right, _bottom)) return -1;
    return sfx(_sound, _gain, _pitchVariation);
}
