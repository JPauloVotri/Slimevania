event_inherited();

SPEED = 5;

ignoreSlopeDown = true;
ignoreSlopeUp = true;

function on_collision(_instance) {
    instance_destroy();
}
