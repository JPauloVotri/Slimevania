// A sala inicial já contém um ponto de partida para uma partida nova.
if (instance_number(oPlayer) > 1) {
    instance_destroy();
    exit;
}

// Herda os eventos do objeto pai
event_inherited();

respawnX = x;
respawnY = y;
isDying = false;
actorManager = new ActorManager(self, {
    can_take_damage: function(_player) {
        return !_player.isDying && _player.stateMachine.state.name != PLAYER_STATES.DASHING;
    },
    on_death: function(_player) {
        _player.begin_death();
    }
});

WATER_HEAL_INTERVAL = game_get_speed(gamespeed_fps) * .5; // meio segundo em frames (30)
STRANGE_WATER_HIT_INTERVAL = game_get_speed(gamespeed_fps) * .8
waterHealTimer = 0;
strangeWaterHitTimer = 0;

GRAVITY = .15;
JUMP_SPEED = 5;
MAX_FALL_SPEED = 4;
MOVEMENT_SPEED = 2;
CLIMB_SPEED = 1.5;
SLIDE_SPEED = 1;
LEDGE_DURATION = 14; // Em frames
LEDGE_MAX_HEIGHT = 32;
LEDGE_REACH = 8;

facing = 0;
climbSide = 0;
ledgeStart = new Vector2(0, 0);
ledgeTarget = new Vector2(0, 0);
keys = { };

#region Powerups
    powersList = [];
    activePower = "";
    recharge = 0;

    // PowerDash
    DASH_DURATION = .2;
    DASH_SPEED = 8;
    DASH_RECHARGE = 2;
    // Alcance horizontal das poses esticadas, por tamanho do jogador.
    DASH_HIT_REACH = [14, 10, 7];
    dashSerial = 0;
#endregion

#region Animação
    ANIM_SPRITES = {
        idle: [sIdlePlayer, sIdleMediumPlayer, sIdleSmallPlayer],
        walk: [sWalkingPlayer, sWalkingMediumPlayer, sWalkingSmallPlayer],
        dash: [sDashingPlayer, sDashingMediumPlayer, sDashingSmallPlayer],
        jump: [sJumpingPlayer, sJumpingMediumPlayer, sJumpingSmallPlayer],
        fall: [sFallingPlayer, sFallingMediumPlayer, sFallingSmallPlayer],
    };

    animName = "idle";

    /// Troca a animação em execução e o sprite do tamanho atual.
    /// @param {String} _name idle, walk, dash, jump ou fall.
    play_animation = function(_name) {
        if (animName == _name) return;

        animName = _name;
        sprite_index = ANIM_SPRITES[$ _name][sizeLevel];
        image_index = 0;
        image_speed = (_name == "jump" || _name == "fall" || _name == "dash") ? 0 : 1;
    }

    /// Escolhe a animação aérea conforme a direção do movimento vertical.
    update_air_animation = function() {
        var _rising = velocity.y < 0;
        var _nextAnimation = _rising ? "jump" : "fall";
        var _changed = animName != _nextAnimation;
        play_animation(_nextAnimation);

        if (!_rising && on_solid(7)) {
            image_index = min(2, image_number - 1);
        } else if (!_changed) {
            var _frameStep = sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps);
            image_index = min(image_index + _frameStep, 1, image_number - 1);
        }
    }
#endregion

#region Tamanho (massa)
    sizeLevel = 0;
    MIN_SIZE_LEVEL = array_length(ANIM_SPRITES.idle) - 1;
    shotsPerSizeLevel = 2;
    shotsOnLevel = 0;

    /// Retorna se o jogador ainda pode atirar.
    /// @returns {Bool} True se o tamanho está acima do mínimo.
    can_shoot = function() {
        return sizeLevel < MIN_SIZE_LEVEL;
    }

    /// Troca o tamanho e aplica o sprite correspondente à animação atual.
    /// @param {Real} _level Nível de tamanho alvo.
    /// @returns {Bool} True quando o nível solicitado foi aplicado.
    set_size_level = function(_level) {
        _level = clamp(_level, 0, MIN_SIZE_LEVEL);
        if (_level == sizeLevel) return true;

        sprite_index = ANIM_SPRITES[$ animName][_level];
        sizeLevel = _level;
        shotsOnLevel = 0;
        return true;
    }

    /// Perde um nível de massa ao atirar.
    shrink = function() {
        return set_size_level(sizeLevel + 1);
    }

    /// Registra um tiro; perde um nível a cada shotsPerSizeLevel tiros.
    register_shot = function() {
        shotsOnLevel++;

        if (shotsOnLevel >= shotsPerSizeLevel) {
            shotsOnLevel = 0;
            shrink();
        }
    }

    /// Aumenta os tiros necessários para perder um nível de massa.
    /// @param {Real} _amount Tiros a adicionar.
    add_shots_per_level = function(_amount) {
        shotsPerSizeLevel += _amount;
    }

    /// Cresce um ou mais níveis de massa.
    /// @param {Real} _levels Níveis a crescer.
    grow = function(_levels = 1) {
        if (sizeLevel == 0) return false;
        return set_size_level(sizeLevel - clamp(_levels, 1, sizeLevel));
    }

    /// Restaura o tamanho cheio.
    reset_size = function() {
        return set_size_level(0);
    }
#endregion

#region Máquina de estados
    stateMachine = new StateMachine();

    #region Funções de controle dos States
        /** Inicia o estado "IDLE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var idle_create = function() {
            play_animation("idle");
        };

        /** Atualiza o estado "IDLE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var idle_update = function() {
            if (set_climbing_state()) return;

            if (!on_solid()) {
                stateMachine.change_state(PLAYER_STATES.ON_AIR);
                return;
            }

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePowers = new PowerUP();
                _usePowers.use_power_up(self.id);
                return;
            }

            var _dir = keys.right - keys.left;

            if (abs(_dir)) {
                stateMachine.change_state(PLAYER_STATES.WALKING);
                return;
            }

            velocity.x = 0;
            velocityReminder.x = 0;

            var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

            if (keys.jump) {
                oGame.inputKeys.pad1.fully_press();
                velocity.y = -JUMP_SPEED;
                stateMachine.change_state(PLAYER_STATES.ON_AIR);
            } else if (_isOnOneWay && keys.descend) {
                y++;
            }
        };

        /** Inicia o estado "WALKING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var walking_create = function() {
            play_animation("walk");
        };

        /** Atualiza o estado "WALKING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var walking_update = function() {
            if (set_climbing_state()) return;

            if (!on_solid()) {
                stateMachine.change_state(PLAYER_STATES.ON_AIR);
                return;
            }

            var _dir = keys.right - keys.left;

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePowers = new PowerUP();
                _usePowers.use_power_up(self.id);
                return;
            }

            if (!abs(_dir)) {
                stateMachine.change_state(PLAYER_STATES.IDLE);
                return;
            }

            velocity.x = _dir * MOVEMENT_SPEED;

            var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

            if (keys.jump) {
                oGame.inputKeys.pad1.fully_press();
                velocity.y = -JUMP_SPEED;
                stateMachine.change_state(PLAYER_STATES.ON_AIR);
            } else if (_isOnOneWay && keys.descend) {
                y++;
            }
        }

        /** Inicia o estado "ON_AIR" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var on_air_create = function() {
            onAirInitialXDirection = sign(velocity.x);
            onAirDirectionChanged = false;

            update_air_animation();
        }

        /** Atualiza o estado "ON_AIR" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var on_air_update = function() {
            if (set_climbing_state()) return;

            velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);
            update_air_animation();

            if (on_solid() and velocity.y > 0) {
                collide_y();
                stateMachine.change_state(PLAYER_STATES.IDLE);
                return;
            }

            if (keys.jumpRelease && velocity.y < 0) {
                oGame.inputKeys.pad1.fully_release();
                velocity.y /= 2;
                velocityReminder.y = 0;
            }

            var _dir = keys.right - keys.left;

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePowers = new PowerUP();
                _usePowers.use_power_up(self.id);
                return;
            }

            if (_dir != onAirInitialXDirection) {
                onAirDirectionChanged = true;
            }

            if (_dir == 0) {
                _dir = sign(velocity.x);
            }

            var _speedMultiplier = onAirDirectionChanged ? .5 : 1;
            velocity.x = _dir * MOVEMENT_SPEED * _speedMultiplier;
        }

        /** Inicia o estado "DASHING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var dashing_create = function() {
            dashSerial++;
            recharge = DASH_RECHARGE;
            ignoreSlopeDown = true;

            play_animation("dash");

            var _direction = new Vector2(
                keys.right - keys.left,
                keys.down - keys.up
            );

            if (_direction.magnitude() == 0) {
                _direction.x = facing;
            }

            var _lenght = _direction.magnitude();

            velocity.rewriteRW(_direction.normalized().scaleRW(DASH_SPEED));

            handle_dash_cracked_block_collision();
        }

        /** Atualiza o estado "DASHING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var dashing_update = function() {
            var _elapsed = stateMachine.time / game_get_speed(gamespeed_fps);
            var _progress = _elapsed / DASH_DURATION;
            var _timeout = _elapsed > DASH_DURATION;

            // Segura a segunda pose e libera as poses finais pelo tempo do dash.
            if (_progress >= .9) {
                image_index = image_number - 1;
            } else if (_progress >= .7) {
                image_index = min(2, image_number - 1);
            } else {
                image_index = min(1, floor(_elapsed * sprite_get_speed(sprite_index)));
            }

            var _mod = stateMachine.time % 2;

            if (_mod == 0) {
                var _trace = instance_create_layer(x, y, "Game", oTrace);

                _trace.sprite_index = sprite_index;
                _trace.image_index = image_index;
                _trace.image_xscale = image_xscale;
                _trace.image_yscale = image_yscale;
                _trace.image_angle  = image_angle;
                _trace.image_speed = 0;
                _trace.image_alpha = .6;
                _trace.depth = depth + 1;

                _trace.on_step = function(_inst) {
                    _inst.image_alpha -= .06;

                    if (_inst.image_alpha <= 0) {
                        instance_destroy(_inst, false);
                    }
                }
            }

            handle_dash_cracked_block_collision();

            if (_timeout || velocity.magnitude() <= 0) {
                stateMachine.change_state(PLAYER_STATES.IDLE);
            }
        }

        /** Encerra o estado "DASHING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var dashing_destroy = function() {
            velocity.rewrite(
                min(abs(velocity.x), MOVEMENT_SPEED) * sign(velocity.x),
                clamp(velocity.y, -JUMP_SPEED / 2, MAX_FALL_SPEED)
            );
            ignoreSlopeDown = false;
        }

        /** Inicia o estado "CLIMBING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var climbing_create = function() {
            climbSide = get_roughcast_block_collision_side();
            facing = climbSide;
            velocity.rewrite(0, SLIDE_SPEED);
            velocityReminder.rewrite(0, 0);

            update_air_animation();
        }

        /** Atualiza o estado "CLIMBING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var climbing_update = function() {
            if (!place_meeting(x + climbSide, y, oRoughcastBlock)) {
                if (keys.up) {
                    var _target = find_ledge_target();

                    if (_target != undefined) {
                        ledgeTarget = _target;   // define ANTES de trocar de estado
                        stateMachine.change_state(PLAYER_STATES.LEDGE);
                        return;
                    }
                }

                stateMachine.change_state(PLAYER_STATES.ON_AIR);
                return;
            }

            if (on_solid() && !keys.up) {
                stateMachine.change_state(PLAYER_STATES.IDLE);
                return;
            }

            var _dir = keys.right - keys.left;

            if (_dir == -climbSide) {
                stateMachine.change_state(PLAYER_STATES.ON_AIR);
                return;
            }

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePower = new PowerUP();
                _usePower.use_power_up(self.id);
                return;
            }

            velocity.x = 0;
            velocityReminder.x = 0;
            velocity.y = keys.up ? -CLIMB_SPEED : SLIDE_SPEED;
            update_air_animation();
        }

        /** Inicia o estado "LEDGE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var ledge_create = function() {
            ledgeStart.rewrite(x, y);
            velocity.rewrite(0, 0);
            velocityReminder.rewrite(0, 0);
            facing = -climbSide;

            play_animation("jump");
            image_index = 0;
            image_speed = 1;
        }

        /** Atualiza o estado "LEDGE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var ledge_update = function() {
            var _t = clamp(stateMachine.time / LEDGE_DURATION, 0, 1);

            // Sobe nos primeiros 60% e desliza pro lado a partir dos 40%
            var _ty = clamp(_t / 0.6, 0, 1);
            var _tx = clamp((_t - 0.4) / 0.6, 0, 1);

            // easing suave (começa rápido, termina devagarinho)
            _ty = 1 - sqr(1 - _ty);
            _tx = 1 - sqr(1 - _tx);

            x = round(lerp(ledgeStart.x, ledgeTarget.x, _tx));
            y = round(lerp(ledgeStart.y, ledgeTarget.y, _ty));

            if (_t >= 1) {
                stateMachine.change_state(PLAYER_STATES.IDLE);
            }
        }

        /** Encerra o estado "LEDGE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var ledge_destroy = function() {
            velocity.rewrite(0, 0);
            velocityReminder.rewrite(0, 0);
        }

        /** Inicia o estado "CUTSCENE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var cutscene_create = function() {
            play_animation("idle");
        };

        /** Atualiza o estado "CUTSCENE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var cutscene_update = function() {
            velocity.x = 0;
            velocityReminder.x = 0;

            // Se pegou o trigger no ar, deixa cair até o chão antes de ficar parado
            if (on_solid() && velocity.y >= 0) {
                velocity.y = 0;
                velocityReminder.y = 0;
            } else {
                velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);
            }
        };
    #endregion

    var idleState = new State(PLAYER_STATES.IDLE)
        .set_create(idle_create)
        .set_update(idle_update);

    var walkingState = new State(PLAYER_STATES.WALKING)
        .set_create(walking_create)
        .set_update(walking_update);

    var onAirState = new State(PLAYER_STATES.ON_AIR)
        .set_create(on_air_create)
        .set_update(on_air_update);

    var dashingState = new State(PLAYER_STATES.DASHING)
        .set_create(dashing_create)
        .set_update(dashing_update)
        .set_destroy(dashing_destroy);

    var climbingState = new State(PLAYER_STATES.CLIMBING)
        .set_create(climbing_create)
        .set_update(climbing_update);

    var ledgeState = new State(PLAYER_STATES.LEDGE)
        .set_create(ledge_create)
        .set_update(ledge_update)
        .set_destroy(ledge_destroy);

    var cutsceneState = new State(PLAYER_STATES.CUTSCENE)
        .set_create(cutscene_create)
        .set_update(cutscene_update);

    stateMachine
        .add_state(idleState)
        .add_state(walkingState)
        .add_state(onAirState)
        .add_state(dashingState)
        .add_state(climbingState)
        .add_state(ledgeState)
        .add_state(cutsceneState);

    sprite_index = ANIM_SPRITES.idle[sizeLevel];
    image_index = 0;
    //image_speed = 1;
#endregion

#region Morte e renascimento
    function begin_death() {
        isDying = true;
        shotFrame = -1;
        velocity.rewrite(0, 0);
        velocityReminder.rewrite(0, 0);
        var _deathSprites = [sDyingPlayer, sDyingMediumPlayer, sDyingSmallPlayer];
        sprite_index = _deathSprites[sizeLevel];
        image_index = 0;
        image_speed = 0;
        oGame.deathPlayer = id;
        audio_pause_all();
    }

    function respawn() {
        x = respawnX;
        y = respawnY;
        actorManager.healActor(hits);
        stateMachine.change_state(PLAYER_STATES.IDLE);
        sizeLevel = 0;
        shotsOnLevel = 0;
        recharge = 0;
        waterHealTimer = 0;
        strangeWaterHitTimer = 0;
        velocity.rewrite(0, 0);
        velocityReminder.rewrite(0, 0);
        facing = 1;
        image_xscale = 1;
        animName = "idle";
        sprite_index = ANIM_SPRITES.idle[sizeLevel];
        image_index = 0;
        image_speed = 1;
        isDying = false;
    }
#endregion

#region Funções do player
	/// Regenera vida enquanto o jogador estiver dentro da água.
	function handle_water_regen() {
	    if (!place_meeting(x, y, oWater)) {
	        waterHealTimer = 0;
	        return;
	    }

	    waterHealTimer++;

	    if (waterHealTimer >= WATER_HEAL_INTERVAL) {
	        waterHealTimer = 0;
	        actorManager.healActor(1);
	    }
	}

	/// Retira vida enquanto o jogador estiver dentro da água estranha.
	function handle_strange_water_hit() {
		if (!place_meeting(x, y, oStrangeWater)) {
			strangeWaterHitTimer = 0;
			return;
		}

		strangeWaterHitTimer++;

		if (strangeWaterHitTimer >= STRANGE_WATER_HIT_INTERVAL) {
			strangeWaterHitTimer = 0;
			actorManager.hit(1);
		}
	}

    /// Destrói blocos quebráveis atingidos durante o dash.
    function handle_dash_cracked_block_collision() {
        var _crackedBlock = instance_place(
            x + velocity.x,
            y + velocity.y,
            oCrackedBlock
        );

        if (_crackedBlock) {
            oGame.roomManager.destroy_connected_block(_crackedBlock);
        }
    }

    /// Detecta inimigos na área percorrida pelo DASH, incluindo entre os pontos de início e fim.
    function hit_enemies_with_dash(_startX, _startY) {
        var _dy = y - _startY;
        var _top = bbox_top - _dy;
        var _bottom = bbox_bottom - _dy;
        var _reach = DASH_HIT_REACH[sizeLevel];
        var _left = x - _reach;
        var _right = x + _reach;
        var _dash = dashSerial;
        var _sweepLeft = min(_startX, x) - _reach;
        var _sweepRight = max(_startX, x) + _reach;
        var _sweepTop = min(_top, bbox_top);
        var _sweepBottom = max(_bottom, bbox_bottom);

        // Varre o trecho horizontal e depois o vertical, na ordem usada pelo movimento.
        with (oEnemy) {
            var _hitX = bbox_left <= _sweepRight && bbox_right >= _sweepLeft
                && bbox_top <= _bottom && bbox_bottom >= _top;
            var _hitY = bbox_left <= _right && bbox_right >= _left
                && bbox_top <= _sweepBottom && bbox_bottom >= _sweepTop;
            if (_hitX || _hitY) receive_dash(_dash);
        }
    }

    /// Coleta o power-up encontrado pelo jogador.
    function handle_power_up_pickup() {
        /// @type {Id.Instance.oPowerUp}
        var _powerUp = instance_place(x, y, oPowerUp);

        if (!_powerUp) return;

        if (!array_contains(powersList, _powerUp.name)) {
            array_push(powersList, _powerUp.name);
            activePower = _powerUp.name;
        }

        oGame.roomManager.destroy_instance_and_persist(_powerUp);
    }

    /// Procura um ponto onde o jogador cabe em cima da borda.
    /// @returns {Struct.Vector2|Undefined}
    function find_ledge_target() {
        var _tx = x + climbSide * LEDGE_REACH;

        for (var _up = 0; _up <= LEDGE_MAX_HEIGHT; _up++) {
            var _ty = y - _up;

            if (!place_meeting(_tx, _ty, oBlock) &&
                place_meeting(_tx, _ty + 1, oBlock)) {
                return new Vector2(_tx, _ty);
            }
        }
    }

    /// Checa se há colisão com um bloco escalável, retornando o lado da colisão.
    function get_roughcast_block_collision_side() {
        if (place_meeting(x + 1, y, oRoughcastBlock)) return 1;
        if (place_meeting(x - 1, y, oRoughcastBlock)) return -1;
        return 0;
    }

    /// Entra em CLIMBING se estiver colidindo com um bloco escalável.
    function set_climbing_state() {
        var _side = get_roughcast_block_collision_side();
        if (_side == 0) return false;

        var _dir = keys.right - keys.left;

        if (_dir == -_side) return false;

        if (on_solid() && !keys.up) return false;

        stateMachine.change_state(PLAYER_STATES.CLIMBING);
        return true;
    }

    /// Congela o jogador para uma cena.
    function start_cutscene() {
        stateMachine.change_state(PLAYER_STATES.CUTSCENE);
    }

    /// Devolve o controle ao jogador.
    function end_cutscene() {
        stateMachine.change_state(PLAYER_STATES.IDLE);
    }

    /// Retorna se o jogador está no meio de uma cutscene.
    /// @returns {Bool}
    function in_cutscene() {
        return stateMachine.state.name == PLAYER_STATES.CUTSCENE;
    }
#endregion

#region Funções de projéteis
    SHOOT_SPRITES = [sShootingPlayer, sShootingMediumPlayer, sShootingSmallPlayer];
    SHOT_RELEASE_FRAME = 4;
    // Posição da boca no quadro de disparo de cada tamanho que pode atirar.
    SHOT_MOUTH = [[20, 27], [19, 28]];
    shotFrame = -1;
    shotDirection = undefined;
    shotFacing = 1;

    /// Atualiza a animação do tiro separadamente da animação de movimento.
    function update_shot() {
        if (shotFrame < 0) return;
        if (in_cutscene()) {
            shotFrame = -1;
            return;
        }

        var _sprite = SHOOT_SPRITES[sizeLevel];
        var _previousFrame = shotFrame;
        shotFrame += sprite_get_speed(_sprite) / game_get_speed(gamespeed_fps);

        if (_previousFrame < SHOT_RELEASE_FRAME && shotFrame >= SHOT_RELEASE_FRAME && can_shoot()) {
            var _mouth = SHOT_MOUTH[sizeLevel];
            var _mouthX = x + (_mouth[0] - sprite_get_xoffset(_sprite)) * shotFacing;
            var _mouthY = y + (_mouth[1] - sprite_get_yoffset(_sprite)) * image_yscale;
            var _direction = shotDirection;

            /// @self Id.Instance.oProjectile
            with (instance_create_depth(_mouthX, _mouthY, depth - 1, oProjectile)) {
                launch(_direction);
            }
            register_shot();
        }

        if (shotFrame >= sprite_get_number(_sprite)) shotFrame = -1;
    }
#endregion
