if (isDying) exit;

if (shotFrame < 0) {
    draw_self();
    exit;
}

draw_sprite_ext(SHOOT_SPRITES[sizeLevel], floor(shotFrame), x, y, shotFacing,
    image_yscale, image_angle, image_blend, image_alpha);
