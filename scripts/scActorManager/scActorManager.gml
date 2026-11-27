/// Gerencia ações acometidas ao Actor
/// @param {Asset.GMObject} _actor Ator que sofre uma ação.
/// @param {Struct} [_config] Opções iniciais.
///		max_life, initial_life e collected_life (todas opcionais).
///		can_take_damage (opcional) recebe o ator e indica se pode sofrer dano.
///		on_death (opcional) recebe o ator quando a vida chega a zero.
///		on_hit (opcional) recebe o ator quando sofre dano sem morrer.
function ActorManager(_actor, _config = {}) constructor {
	actor = _actor;
	can_take_damage = _config[$ "can_take_damage"];
	on_death = _config[$ "on_death"];
	on_hit = _config[$ "on_hit"];
	
	static init = function(_config) {
		actor.MAX_LIFE =		_config[$ "max_life"]		?? 80;
		actor.INITIAL_LIFE =	_config[$ "initial_life"]	?? 12;
		actor.collected_life =  _config[$ "collected_life"] ?? 0;
	}
	
	static hit = function(_dmg) {
		if (!is_undefined(can_take_damage) && !can_take_damage(actor)) return;
		full_life = actor.INITIAL_LIFE + actor.collected_life;
		var _wasAlive = actor.hits < full_life;
		actor.hits = min(full_life, actor.hits + _dmg);
		if (_wasAlive && actor.hits >= full_life) {
			if (!is_undefined(on_death)) on_death(actor);
		} else if (_wasAlive && !is_undefined(on_hit)) {
			on_hit(actor);
		}
	}
	
	static getHealth = function() {
		return actor.INITIAL_LIFE + actor.collected_life - actor.hits;
	}
	
	static healActor = function(_healValue) {
		actor.hits = max(actor.hits - _healValue, 0);
	}
	
	static boostHealth = function() {
		actor.collected_life = min(actor.collected_life + 4, actor.MAX_LIFE - actor.INITIAL_LIFE);
	}
	
	init(_config);
}
