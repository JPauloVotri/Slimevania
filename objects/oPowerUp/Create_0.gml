if (!variable_global_exists("powerups")) {
    global.powerups = [];
}

if (array_contains(global.powerups, power_id)) {
	instance_destroy();
}