if (surface_exists(viewSurface)) {
    draw_surface_part(
        viewSurface,
        frac(x),
        frac(y),
        gameSize.x,
        gameSize.y,
        0,
        0
    );
}
