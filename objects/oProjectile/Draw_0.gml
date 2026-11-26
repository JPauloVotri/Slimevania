// A gota do jogador fica dois pixels à direita da origem do sprite.
var _offset = sprite_index == sProjectilePlayer ? -2 : 0;
draw_sprite_ext(sprite_index, floor(image_index),
    x + lengthdir_x(_offset, travelAngle), y + lengthdir_y(_offset, travelAngle),
    image_xscale, image_yscale, travelAngle, image_blend, image_alpha);
