// Herda os eventos do objeto pai
event_inherited();

GRAVITY = .15;
JUMP_SPEED = 5;
MAX_FALL_SPEED = 4;
MOVEMENT_SPEED = 2;

keys = { };

#region Máquina de estados
    enum STATES {
        IDLE,
        WALKING,
        ON_AIR,
    }

    stateMachine = new StateMachine();

    #region Funções de controle dos States
        /** Atualiza o estado "IDLE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var idle_update = function() {
            if (!on_solid()) {
                stateMachine.change_state(STATES.ON_AIR);
                return;
            }

            var _dir = keys.right - keys.left;

            if (abs(_dir)) {
                stateMachine.change_state(STATES.WALKING);
                return;
            }

            velocity.x = 0;
            velocityReminder.x = 0;

            var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

            if (keys.jump) {
                velocity.y = -JUMP_SPEED;
            } else if (_isOnOneWay && keys.down) {
                y++;
            }
        };

        /** Atualiza o estado "WALKING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var walking_update = function() {
            if (!on_solid()) {
                stateMachine.change_state(STATES.ON_AIR);
                return;
            }

            var _dir = keys.right - keys.left;

            if (!abs(_dir)) {
                stateMachine.change_state(STATES.IDLE);
                return;
            }

            velocity.x = _dir * MOVEMENT_SPEED;

            var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

            if (keys.jump) {
                velocity.y = -JUMP_SPEED;
            } else if (_isOnOneWay && keys.down) {
                y++;
            }
        }

        /** Inicia o estado "ON_AIR" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var on_air_create = function() {
            onAirInitialXDirection = sign(velocity.x);
        }

        /** Atualiza o estado "ON_AIR" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var on_air_update = function() {
            velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);

            if (on_solid() and velocity.y > 0) {
                collide_y();
                stateMachine.change_state(STATES.IDLE);
                return;
            }

            if (keys.jumpRelease && velocity.y < 0) {
                velocity.y /= 2;
                velocityReminder.y = 0;
            }

            var _dir = keys.right - keys.left;

            if (_dir != 0 && _dir != onAirInitialXDirection) {
                onAirInitialXDirection = 0;
                velocity.x = _dir * MOVEMENT_SPEED / 2;
            } else if (_dir == 0) {
                onAirInitialXDirection = 0;
                velocity.x = sign(velocity.x) * MOVEMENT_SPEED / 2;
            }
        }
    #endregion

    var idleState = new State(STATES.IDLE)
        .set_update(idle_update);

    var walkingState = new State(STATES.WALKING)
        .set_update(walking_update);

    var onAirState = new State(STATES.ON_AIR)
        .set_create(on_air_create)
        .set_update(on_air_update);

    stateMachine
        .add_state(idleState)
        .add_state(walkingState)
        .add_state(onAirState);
#endregion
