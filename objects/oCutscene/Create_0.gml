shadow = noone;
finished = false;

function createActor(_x, _y, _layer, _obj, _vars = {}) {
	if (!instance_exists(shadow)) {
		shadow = instance_create_layer(_x, _y, _layer, _obj, _vars);
	}
}

function destroyActor() {
	if (instance_exists(shadow)) {
		instance_destroy(shadow);
	}
	
	shadow = noone;
	finished = true;
}

function start(_inst) {
	if (finished) return;
	
	if (!instance_exists(_inst)) {
		createActor(192, 64, "Game", _inst, variables);
	}
}