event_inherited();

enum ENEMY_STATE { IDLE, COMBAT, DODGE, DEAD }

GRAVITY = .15;
MAX_FALL_SPEED = 4;
MOVE_SPEED = 2;
JUMP_SPEED = 4;
JUMP_HOLD_GRAVITY = .1;
JUMP_HOLD_STEPS = 12;
MIN_DISTANCE = 80;
MAX_DISTANCE = 200;
SHOT_RELEASE_FRAME = 4;
SHOT_AIM_TIME = .2;
SHOT_COOLDOWN = 1.2;
DASH_REACTION_TIME = .15;
DODGE_COOLDOWN = 1.5;
DODGE_DURATION = .35;

MAX_LIFE = 10;
health = MAX_LIFE;
lastDash = -1;
enemyState = ENEMY_STATE.IDLE;
target = noone;
moveDirection = 0;
repositionDirection = 1;
moveDecisionTime = 0;
navigationJump = false;
jumpHoldSteps = 0;
jumpTravelSteps = 0;
jumpDelaySteps = 0;
dropEdgeX = undefined;
repositionJumpTime = .8;
dashThreatTime = 0;
dodgeCooldown = 0;
dodgeTime = 0;
shotFrame = -1;
shotCooldown = 0;
var _diagonal = sqrt(.5);
shotDirections = [[1, 0], [_diagonal, -_diagonal], [0, -1], [-_diagonal, -_diagonal],
    [-1, 0], [-_diagonal, _diagonal], [0, 1], [_diagonal, _diagonal]];

/// O jogador chama esta função somente quando a área percorrida pelo DASH acerta a slime.
function receive_dash(_dash) {
    if (enemyState == ENEMY_STATE.DEAD || lastDash == _dash) return;
    lastDash = _dash;
    receive_damage(2);
}

/// Retorna se o dano foi aplicado a um inimigo vivo.
function receive_damage(_damage) {
    if (enemyState == ENEMY_STATE.DEAD) return false;
    health = max(0, health - _damage);
    if (health > 0) {
        sfx(sndEnemyHurt, .7);
        return true;
    }

    sfx(sndEnemyDeath, .9);

    // A sala recria a instância na posição inicial, mesmo que ela tenha se movido.
    oGame.roomManager.register_destroyed_instance(room, object_index, xstart, ystart);
    enemyState = ENEMY_STATE.DEAD;
    shotFrame = -1;
    velocity.rewrite(0, 0);
    sprite_index = sDyingEnemy;
    image_index = 0;
    image_speed = 1;
    return true;
}

function solid_at(_x, _y) {
    return place_meeting(_x, _y, oBlock);
}

function platform_below(_x, _y) {
    var _platform = instance_place(_x, _y + 1, oBlock);
    if (_platform != noone) return _platform;
    if (place_meeting(_x, _y, oOneWayBlock)) return noone;
    return instance_place(_x, _y + 1, oOneWayBlock);
}

function ground_at(_x, _y) {
    return platform_below(_x, _y) != noone;
}

function walkable(_direction) {
    var _x = x + _direction * MOVE_SPEED;
    if (check_room_limits_collision(_x - x, 0)) return false;
    if (!solid_at(_x, y) && (ground_at(_x, y) || ground_at(_x, y + 1))) return true;
    return solid_at(_x, y) && !solid_at(_x, y - 1) && ground_at(_x, y - 1);
}

function jump_gravity(_vy, _holdSteps) {
    return (_vy < 0 && _holdSteps > 0) ? JUMP_HOLD_GRAVITY : GRAVITY;
}

/// Procura uma aterrissagem local usando a mesma gravidade aplicada no Step.
function predict_jump_landing(_direction, _holdSteps, _travelSteps, _delaySteps = 0) {
    var _testX = x;
    var _testY = y;
    var _vy = -JUMP_SPEED;
    var _yRemainder = 0;
    repeat (64) {
        if (_delaySteps > 0) {
            _delaySteps--;
        } else if (_travelSteps > 0) {
            _travelSteps--;
            repeat (MOVE_SPEED) {
                _testX += _direction;
                if (_testX + bbox_left - x < 0 || _testX + bbox_right - x >= room_width
                        || solid_at(_testX, _testY)) return undefined;
            }
        }
        _vy = min(_vy + jump_gravity(_vy, _holdSteps), MAX_FALL_SPEED);
        _holdSteps--;
        _yRemainder += _vy;
        var _dy = sign(_yRemainder) * floor(abs(_yRemainder));
        _yRemainder -= _dy;
        var _stepY = sign(_dy);
        repeat (abs(_dy)) {
            var _nextY = _testY + _stepY;
            if (_nextY + bbox_top - y < 0 || _nextY + bbox_bottom - y >= room_height) return undefined;
            if (_stepY > 0) {
                var _platform = platform_below(_testX, _testY);
                if (_platform != noone) return { x: _testX, y: _testY, platform: _platform };
            }
            if (solid_at(_testX, _nextY)) return undefined;
            _testY = _nextY;
        }
    }
    return undefined;
}

function begin_jump(_direction, _holdSteps, _travelSteps, _delaySteps = 0) {
    moveDirection = _direction;
    velocity.y = -JUMP_SPEED;
    velocityReminder.rewrite(0, 0);
    jumpHoldSteps = _holdSteps;
    jumpTravelSteps = _travelSteps;
    jumpDelaySteps = _delaySteps;
    navigationJump = true;
    repositionJumpTime = random_range(1.2, 1.8);
}

/// Prefere o salto normal. Segura o pulo se for necessário atingir a aterrissagem.
function try_jump(_direction) {
    for (var _hold = 0; _hold <= JUMP_HOLD_STEPS; _hold += JUMP_HOLD_STEPS) {
        var _landing = predict_jump_landing(_direction, _hold, 64);
        if (!is_undefined(_landing)) {
            begin_jump(_direction, _hold, 64);
            return true;
        }
    }
    return false;
}

/// Procura o primeiro chão embaixo da borda ou da plataforma atravessável.
function predict_drop_landing(_x) {
    var _testY = y;
    var _feetOffset = bbox_bottom - y;
    while (_testY + _feetOffset < room_height - 1) {
        if (solid_at(_x, _testY + 1)) return _testY;
        _testY++;
        if (ground_at(_x, _testY)) return _testY;
    }
    return undefined;
}

function try_platform_drop(_player, _escape) {
    var _candidates = [];
    var _oneWay = noone;
    if (!solid_at(x, y + 1)) {
        _oneWay = platform_below(x, y);
        if (_oneWay != noone) array_push(_candidates, x);
    }

    // Planeja a caminhada até a primeira borda acessível em cada direção.
    for (var _dir = -1; _dir <= 1; _dir += 2) {
        for (var _edgeX = x + _dir; !check_room_limits_collision(_edgeX - x, 0); _edgeX += _dir) {
            if (_edgeX + bbox_left - x < 0 || _edgeX + bbox_right - x >= room_width
                    || solid_at(_edgeX, y)) break;
            if (!ground_at(_edgeX, y)) {
                if (!ground_at(_edgeX, y + 1)) array_push(_candidates, _edgeX);
                break;
            }
        }
    }

    var _bestX = undefined;
    var _bestScore = _escape ? 0 : -infinity;
    var _distance = point_distance(x, y, _player.x, _player.y);
    for (var _i = 0; _i < array_length(_candidates); _i++) {
        var _candidateX = _candidates[_i];
        var _landingY = predict_drop_landing(_candidateX);
        if (is_undefined(_landingY) || _landingY - y < 12) continue;

        var _landingDistance = point_distance(_candidateX, _landingY, _player.x, _player.y);
        var _heightGain = abs(y - _player.y) - abs(_landingY - _player.y);
        if (!_escape && _heightGain <= 0) continue;
        var _score = _escape ? _landingDistance - _distance : _distance - _landingDistance + _heightGain;
        if (_score > _bestScore) {
            _bestScore = _score;
            _bestX = _candidateX;
        }
    }

    if (is_undefined(_bestX)) return false;
    if (_bestX == x) {
        // Passa o pé pela superfície para que a colisão unidirecional libere a queda.
        y += max(1, _oneWay.bbox_top - bbox_bottom + 1);
        moveDirection = 0;
        navigationJump = true;
        jumpDelaySteps = 0;
        jumpTravelSteps = 0;
    } else {
        dropEdgeX = _bestX;
        moveDirection = sign(dropEdgeX - x);
    }
    repositionJumpTime = random_range(1.2, 1.8);
    return true;
}

/// Planeja a distância horizontal até cada plataforma e testa o arco curto antes do segurado.
function try_platform_jump(_player, _escape) {
    var _distance = point_distance(x, y, _player.x, _player.y);
    var _feet = bbox_bottom;
    var _reach = MOVE_SPEED * 64;
    var _platforms = ds_list_create();
    var _types = [oBlock, oOneWayBlock];
    var _bestJump = undefined;
    var _bestScore = _escape ? 0 : -infinity;
    for (var _type = 0; _type < array_length(_types); _type++) {
        var _count = collision_rectangle_list(x - _reach, _feet - 65, x + _reach, _feet - 16,
            _types[_type], false, false, _platforms, false);
        for (var _i = 0; _i < _count; _i++) {
            var _platform = _platforms[| _i];
            var _rise = _feet - _platform.bbox_top;
            if (_rise < 16 || _rise > 65) continue;

            var _left = _platform.bbox_left;
            var _right = _platform.bbox_right;
            var _targetX = _escape ? (_player.x < x ? _right : _left) : _player.x;
            var _positions = [clamp(x, _left, _right), (_left + _right) * .5, clamp(_targetX, _left, _right)];
            var _delays = [0, 10, 18];
            for (var _hold = 0; _hold <= JUMP_HOLD_STEPS; _hold += JUMP_HOLD_STEPS) {
                var _reachable = false;
                for (var _j = 0; _j < array_length(_positions); _j++) {
                    var _dx = _positions[_j] - x;
                    var _direction = sign(_dx);
                    var _travel = round(abs(_dx) / MOVE_SPEED);
                    if (_travel > 64) continue;

                    for (var _d = 0; _d < array_length(_delays); _d++) {
                        var _delay = _delays[_d];
                        var _landing = predict_jump_landing(_direction, _hold, _travel, _delay);
                        if (is_undefined(_landing) || _landing.platform != _platform) continue;
                        _reachable = true;

                        var _landingDistance = point_distance(_landing.x, _landing.y, _player.x, _player.y);
                        var _score = _escape
                            ? _landingDistance - _distance + max(0, _player.y - _landing.y) * .5
                            : _distance - _landingDistance;
                        if (_score > _bestScore) {
                            _bestScore = _score;
                            _bestJump = [_direction, _hold, _travel, _delay];
                        }
                        break;
                    }
                }
                if (_reachable) break;
            }
        }
        ds_list_clear(_platforms);
    }
    ds_list_destroy(_platforms);
    if (is_undefined(_bestJump)) return false;

    begin_jump(_bestJump[0], _bestJump[1], _bestJump[2], _bestJump[3]);
    return true;
}

function dash_threatens(_player, _fps) {
    if (_player.stateMachine.state.name != PLAYER_STATES.DASHING) return false;
    var _steps = max(0, _player.DASH_DURATION * _fps - _player.stateMachine.time);
    var _vx = _player.velocity.x;
    var _vy = _player.velocity.y;
    if ((_vx == 0 && _vy == 0) || (_steps <= 0)) return false;

    // Amostra a caixa do jogador na trajetória restante do DASH.
    for (var _t = .5; _t <= _steps; _t += .5) {
        var _dx = _vx * _t;
        var _dy = _vy * _t;
        if (collision_rectangle(_player.bbox_left + _dx, _player.bbox_top + _dy,
                _player.bbox_right + _dx, _player.bbox_bottom + _dy, oBlock, false, false) != noone) break;
        if (_player.bbox_left + _dx <= bbox_right && _player.bbox_right + _dx >= bbox_left
                && _player.bbox_top + _dy <= bbox_bottom && _player.bbox_bottom + _dy >= bbox_top) return true;
    }
    return false;
}

function choose_movement(_player, _grounded) {
    var _toward = sign(_player.x - x);
    if (_toward == 0) _toward = image_xscale;
    var _distance = point_distance(x, y, _player.x, _player.y);
    if (_distance < MIN_DISTANCE) {
        moveDirection = -_toward;
    } else if (_distance > MAX_DISTANCE) {
        moveDirection = _toward;
    } else {
        repositionDirection *= -1;
        moveDirection = repositionDirection;
    }
    moveDecisionTime = random_range(.3, .8);

    if (!_grounded) return;
    if (_player.y > y + 16 && _distance >= MIN_DISTANCE && try_platform_drop(_player, false)) return;
    var _canWalk = walkable(moveDirection);
    var _seekHeight = _player.y < y - 16 && moveDirection == _toward;
    if (_seekHeight && try_platform_jump(_player, false)) return;
    if (_distance <= MAX_DISTANCE && repositionJumpTime <= 0) {
        if (_distance < MIN_DISTANCE && (try_platform_jump(_player, true) || try_platform_drop(_player, true))) return;
        if (try_jump(moveDirection) || try_jump(-moveDirection) || try_jump(0)) return;
        repositionJumpTime = .5;
    }
    if (!_canWalk && !try_jump(moveDirection)) {
        moveDirection = walkable(-moveDirection) ? -moveDirection : 0;
    }
}

function start_dodge(_player, _grounded) {
    dropEdgeX = undefined;
    var _away = sign(x - _player.x);
    if (_away == 0) _away = -image_xscale;
    if (!navigationJump) moveDirection = _away;
    if (_grounded) {
        if (!try_platform_jump(_player, true) && !try_platform_drop(_player, true)
                && !try_jump(_away) && !try_jump(0) && !walkable(_away)) {
            moveDirection = walkable(-_away) ? -_away : 0;
        }
    }
    enemyState = ENEMY_STATE.DODGE;
    dodgeTime = DODGE_DURATION;
    dodgeCooldown = DODGE_COOLDOWN;
    dashThreatTime = 0;
    shotFrame = -1;
}

/// Estima o alvo no instante em que o projétil deve chegar.
function predict_shot_target(_player, _dt) {
    var _centerX = (_player.bbox_left + _player.bbox_right) * .5;
    var _centerY = (_player.bbox_top + _player.bbox_bottom) * .5;
    var _remainingAim = (1 - max(0, shotFrame) / SHOT_RELEASE_FRAME) * SHOT_AIM_TIME / _dt;
    var _maxLead = 30;
    if (_player.stateMachine.state.name == PLAYER_STATES.DASHING) {
        _maxLead = clamp(_player.DASH_DURATION / _dt - _player.stateMachine.time, 0, _maxLead);
    }
    var _vx = _player.velocity.x;
    var _vy = _player.velocity.y;
    var _predictedX = _centerX;
    var _predictedY = _centerY;
    repeat (2) {
        var _flight = point_distance(x, y + 11, _predictedX, _predictedY) / SLIME_PROJECTILE_SPEED;
        var _lead = min(_maxLead, _remainingAim + _flight);
        _predictedX = clamp(_centerX + _vx * _lead, 0, room_width - 1);
        _predictedY = clamp(_centerY + _vy * _lead, 0, room_height - 1);
    }
    // Reduz a previsão quando o deslocamento estimado atravessaria terreno.
    repeat (3) {
        if (collision_line(_centerX, _centerY, _predictedX, _predictedY, oBlock, true, false) == noone
                && (_predictedY <= _centerY || collision_line(_centerX, _centerY, _predictedX, _predictedY,
                    oOneWayBlock, true, false) == noone)) break;
        _predictedX = lerp(_centerX, _predictedX, .5);
        _predictedY = lerp(_centerY, _predictedY, .5);
    }
    return { x: _predictedX, y: _predictedY };
}

function choose_shot(_target) {
    var _bestMiss = max(12, point_distance(x, y + 11, _target.x, _target.y) * .42);
    var _bestShot = undefined;
    for (var _i = 0; _i < array_length(shotDirections); _i++) {
        var _dir = shotDirections[_i];
        var _facing = _dir[0] == 0 ? image_xscale : sign(_dir[0]);
        var _mouthX = x + 2 * _facing;
        var _mouthY = y + 11;
        var _dx = _target.x - _mouthX;
        var _dy = _target.y - _mouthY;
        var _along = _dx * _dir[0] + _dy * _dir[1];
        var _miss = abs(_dx * _dir[1] - _dy * _dir[0]);
        if (_along <= 0 || _miss >= _bestMiss) continue;

        var _endX = _mouthX + _dir[0] * _along;
        var _endY = _mouthY + _dir[1] * _along;
        if (collision_line(_mouthX, _mouthY, _endX, _endY, oBlock, true, false) != noone
                || (_dir[1] > 0 && collision_line(_mouthX, _mouthY, _endX, _endY, oOneWayBlock, true, false) != noone)) continue;

        _bestMiss = _miss;
        _bestShot = { mouthX: _mouthX, mouthY: _mouthY, facing: _facing, direction: _dir };
    }
    return _bestShot;
}

function update_attack(_player, _dt) {
    shotCooldown = max(0, shotCooldown - _dt);
    if (enemyState != ENEMY_STATE.COMBAT) return;
    if (shotFrame >= SHOT_RELEASE_FRAME) {
        shotFrame += sprite_get_speed(sShootingEnemy) * _dt;
        if (shotFrame >= sprite_get_number(sShootingEnemy)) shotFrame = -1;
        return;
    }
    if (shotFrame < 0 && shotCooldown > 0) return;

    var _shot = choose_shot(predict_shot_target(_player, _dt));
    if (is_undefined(_shot)) {
        shotFrame = -1;
        return;
    }
    image_xscale = _shot.facing;

    if (shotFrame < 0) {
        shotFrame = 0;
        return;
    }
    shotFrame += SHOT_RELEASE_FRAME / SHOT_AIM_TIME * _dt;
    if (shotFrame < SHOT_RELEASE_FRAME) return;

    var _direction = new Vector2(_shot.direction[0], _shot.direction[1]);
    /// @self Id.Instance.oProjectileEnemy
    with (instance_create_depth(_shot.mouthX, _shot.mouthY, depth - 1, oProjectileEnemy)) {
        launch(_direction);
    }
    sfx_at(sndEnemyShoot, x, y, .6, .08);
    shotCooldown = SHOT_COOLDOWN;
}

function update_combat_sprite(_grounded) {
    var _sprite = sIdleEnemy;
    if (shotFrame >= 0) {
        _sprite = sShootingEnemy;
    } else if (!_grounded) {
        _sprite = velocity.y < 0 ? sJumpingEnemy : sFallingEnemy;
    } else if (velocity.x != 0) {
        _sprite = sWalkingEnemy;
    }
    if (sprite_index != _sprite) {
        sprite_index = _sprite;
        image_index = 0;
        image_speed = (_sprite == sJumpingEnemy || _sprite == sFallingEnemy || _sprite == sShootingEnemy) ? 0 : 1;
    }
    if (shotFrame >= 0) {
        image_index = floor(shotFrame);
    } else if (!_grounded) {
        image_index = min(2, floor(abs(velocity.y)));
    }
}
