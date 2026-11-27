time++;

for (var _i = 0; _i < array_length(particles); _i++) {
    var _p = particles[_i];
    _p.x += _p.vx + sin(time * .01 + _p.phase) * .08;
    _p.y += _p.vy;

    // Recicla quem saiu da sala, nascendo de novo embaixo.
    if (_p.y < -8 || _p.x < -8 || _p.x > room_width + 8) {
        particles[_i] = new_particle(random(room_width), room_height + 4);
    }
}
