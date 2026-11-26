var _frameStep = sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps);
if (hasImpacted) {
    image_index += _frameStep;
    if (image_index >= image_number) instance_destroy();
    exit;
}

image_index = (image_index + _frameStep) mod IMPACT_FRAME;
move(velocity, on_collision, on_collision);

// Se os dois eixos forem processados no mesmo Step, mantém a posição do primeiro impacto.
if (hasImpacted) {
    x = impactX;
    y = impactY;
}
