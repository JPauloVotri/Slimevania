if (enemyState == ENEMY_STATE.DEAD) exit;

var _fps = game_get_speed(gamespeed_fps);
var _dt = 1 / _fps;
var _grounded = velocity.y >= 0 && on_solid();
if (_grounded) navigationJump = false;
dodgeCooldown = max(0, dodgeCooldown - _dt);

target = instance_find(oPlayer, 0);
if (target == noone || target.actorManager.getHealth() <= 0) {
    target = noone;
    enemyState = ENEMY_STATE.IDLE;
    moveDirection = 0;
    dropEdgeX = undefined;
    moveDecisionTime = 0;
    repositionJumpTime = .8;
    dashThreatTime = 0;
    shotFrame = -1;
    shotCooldown = 0;
} else {
    if (enemyState == ENEMY_STATE.IDLE) enemyState = ENEMY_STATE.COMBAT;
    if (_grounded) repositionJumpTime -= _dt;

    if (enemyState == ENEMY_STATE.DODGE) {
        dodgeTime -= _dt;
        if (dodgeTime <= 0) {
            enemyState = ENEMY_STATE.COMBAT;
            moveDecisionTime = 0;
        }
    }

    if (enemyState == ENEMY_STATE.COMBAT) {
        if (dodgeCooldown <= 0 && dash_threatens(target, _fps)) {
            dashThreatTime += _dt;
            if (dashThreatTime >= DASH_REACTION_TIME) start_dodge(target, _grounded);
        } else {
            dashThreatTime = 0;
        }

        if (enemyState == ENEMY_STATE.COMBAT) {
            moveDecisionTime -= _dt;
            if (!navigationJump && is_undefined(dropEdgeX) && moveDecisionTime <= 0) choose_movement(target, _grounded);
        }
    }
}

var _approachingDrop = !is_undefined(dropEdgeX);
if (_grounded && !_approachingDrop && velocity.y >= 0 && moveDirection != 0 && !walkable(moveDirection)) {
    moveDirection = 0;
    moveDecisionTime = 0;
}
velocity.x = moveDirection * MOVE_SPEED;
if (_approachingDrop) velocity.x = clamp(dropEdgeX - x, -MOVE_SPEED, MOVE_SPEED);
if (navigationJump) {
    if (jumpDelaySteps > 0) {
        jumpDelaySteps--;
        velocity.x = 0;
    } else if (jumpTravelSteps > 0) {
        jumpTravelSteps--;
    } else {
        velocity.x = 0;
    }
}
if (velocity.x == 0) velocityReminder.x = 0;
velocity.y = min(velocity.y + jump_gravity(velocity.y, jumpHoldSteps), MAX_FALL_SPEED);
jumpHoldSteps = max(0, jumpHoldSteps - 1);
ignoreSlopeUp = navigationJump || _approachingDrop;
ignoreSlopeDown = navigationJump || _approachingDrop;
var _startX = x;
move(velocity);

if (_approachingDrop && (x == dropEdgeX || x == _startX)) {
    if (x == dropEdgeX) {
        navigationJump = true;
        jumpDelaySteps = 0;
        jumpTravelSteps = 0;
    }
    dropEdgeX = undefined;
    moveDirection = 0;
    moveDecisionTime = 0;
}

if (shotFrame < 0 && velocity.x != 0) image_xscale = sign(velocity.x);
if (target != noone) update_attack(target, _dt);
update_combat_sprite(velocity.y >= 0 && on_solid());
