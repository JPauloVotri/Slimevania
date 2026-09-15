if (!variable_global_exists("brokenBlocks")) {
    global.brokenBlocks = [];
}

if (array_contains(global.brokenBlocks, block_id)) {
    instance_destroy();
}
