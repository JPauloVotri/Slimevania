if (!variable_global_exists("blocos_quebrados")) {
    global.blocos_quebrados = [];
}

if (array_contains(global.blocos_quebrados, block_id)) {
	instance_destroy();
}