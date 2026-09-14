var _followedSpeed = new Vector2(0, 0);

if (target != noone) {
    goTo.rewrite(
        target.x + sign(target.velocity.x) * 128 - (gameSize.x * .5),
        target.y + sign(target.velocity.y) * 64 - (gameSize.y * .5)
    );
    _followedSpeed = target.velocity;
}

var _position = new Vector2(x, y);
var _delta = goTo.copy().subtractRW(_position);
var _distance = _delta.abs();
var _direction = _delta.sign();
var _smoothness = _distance.copy()
    .componentMultiplyRW(new Vector2(.04, .02));
var _minSpeed = _followedSpeed.abs().componentMultiplyRW(new Vector2(1.1, 1.2));
var _speed = new Vector2(
    max(_smoothness.x, _minSpeed.x),
    max(_smoothness.y, _minSpeed.y)
)

if (abs(_followedSpeed.x) > 0) {
    _position.x += min(_speed.x, _distance.x) * _direction.x;
}
_position.y += min(_speed.y, _distance.y) * _direction.y;

x = clamp(_position.x, 0, room_width - gameSize.x);
y = clamp(_position.y, 0, room_height - gameSize.y);
