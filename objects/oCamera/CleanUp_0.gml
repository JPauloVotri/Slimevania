if (surface_exists(viewSurface)) {
    surface_free(viewSurface);
    viewSurface = -1;
}
if (surface_exists(deathSurface)) surface_free(deathSurface);
