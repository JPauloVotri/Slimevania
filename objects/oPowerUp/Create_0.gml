if (!variable_global_exists("powerUps")) {
    global.powerUps = [];
}

if (array_contains(global.powerUps, powerId)) {
    instance_destroy();
}
