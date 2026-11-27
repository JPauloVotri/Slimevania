time++;

// Bloco quebrado pelo dash (ou recriado): refaz o terreno.
var _count = instance_number(oBlock) + instance_number(oOneWayBlock);
if (_count != blockCount) {
    blockCount = _count;
    terrainDirty = true;
}
