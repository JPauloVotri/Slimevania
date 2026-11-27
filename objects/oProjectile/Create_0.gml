event_inherited();

#macro SLIME_PROJECTILE_SPEED 5
SPEED = SLIME_PROJECTILE_SPEED;
IMPACT_FRAME = 4;
image_index = 0;
image_speed = 0;
travelAngle = 0;
hasImpacted = false;
impactX = x;
impactY = y;

ignoreSlopeDown = true;
ignoreSlopeUp = true;

function launch(_direction) {
    velocity.rewriteRW(_direction.copy().scaleRW(SPEED));
    travelAngle = point_direction(0, 0, velocity.x, velocity.y);
}

function on_collision(_instance) {
    if (hasImpacted) return;
    hasImpacted = true;
    sfx_at(sndProjectileHit, x, y, .5, .12);
    impactX = x;
    impactY = y;
    velocity.rewrite(0, 0);
    image_index = IMPACT_FRAME;
}
