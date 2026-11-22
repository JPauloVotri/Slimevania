/// Gerencia ações acometidas ao Actor
/// @param {Asset.GMObject} _actor Ator que sofre uma ação.
/// @param {Struct} [_config] Opções iniciais.
///		max_life, initial_life e collected_life (todas opcionais).
function ActorManager(_actor, _config = {}) constructor {
	actor = _actor;
	
	static init = function(_config) {
		actor.MAX_LIFE =		_config[$ "max_life"]		?? 80;
		actor.INITIAL_LIFE =	_config[$ "initial_life"]	?? 12;
		actor.collected_life =  _config[$ "collected_life"] ?? 0;
	}
	
	static hit = function(_dmg) {
		full_life = actor.INITIAL_LIFE + actor.collected_life;
		
		actor.hits = min(full_life, actor.hits + _dmg);
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