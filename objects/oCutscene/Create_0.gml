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

function start(_inst, _x, _y) {
	if (finished) return;
	
	if (!instance_exists(_inst)) {
		createActor(_x, _y, "Game", _inst, variables);
	}
}
