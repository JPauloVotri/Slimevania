/// Cria uma instância de menu na tela com as opções e uma função opcional de inicialização.
/// @param {Real} _x Posição X inicial do menu na tela.
/// @param {Real} _y Posição Y inicial do menu na tela.
/// @param {Real|Array<Real>} _margin Margem opcional ao redor do menu. Se for -1, o menu ocupará toda a tela.
/// @param {Real|Array<Real>} _padding Preenchimento opcional dentro do menu, entre a borda e as opções.
/// @param {Real|Array<Real>} _optionBorder Borda opcional ao redor de cada opção do menu.
/// @param {Array<Struct.MenuOption>} _options Lista de opções exibidas no menu.
/// @param {[Asset.GMFont|Undefined]} _font Fonte utilizada para renderizar o texto.
/// @param {[String|Undefined]} [_description] Texto descritivo opcional do menu.
/// @param {[Bool]} _isHorizontal Indica se as opções devem ser exibidas horizontalmente.
/// @param {[Function|Undefined]} [_on_create] Callback executado após a criação da instância do menu.
/// @returns {Id.Instance.oMenu} A instância do menu criada.
function menu(_x, _y, _margin, _padding, _optionBorder, _options, _font = undefined, _description = undefined,
        _isHorizontal = false, _on_create = undefined) {
    var _menuInstance = instance_create_depth(_x, _y, -999, oMenu);

    /// @self Id.Instance.oMenu
    with (_menuInstance) {
        options = _options;
        description = _description;
        optionsCount = array_length(_options);
        isHorizontal = _isHorizontal;
        font = _font;

        if (isHorizontal) {
            inputs.previous = INPUT_KEYS.left;
            inputs.next = INPUT_KEYS.right;
        } else {
            inputs.previous = INPUT_KEYS.up;
            inputs.next = INPUT_KEYS.down;
        }

        #region Opções
            if (is_real(_optionBorder)) {
                optionsBorder.left = _optionBorder;
                optionsBorder.right = _optionBorder;
                optionsBorder.top = _optionBorder;
                optionsBorder.bottom = _optionBorder;
            } else if (is_array(_optionBorder)) {
                if (array_length(_optionBorder) == 4) {
                    optionsBorder.left = _optionBorder[0];
                    optionsBorder.right = _optionBorder[1];
                    optionsBorder.top = _optionBorder[2];
                    optionsBorder.bottom = _optionBorder[3];
                } else if (array_length(_optionBorder) == 2) {
                    optionsBorder.left = _optionBorder[0];
                    optionsBorder.right = _optionBorder[0];
                    optionsBorder.top = _optionBorder[1];
                    optionsBorder.bottom = _optionBorder[1];
                }
            }

            if (!is_undefined(font)) {
                draw_set_font(font);
            }

            for (var _i = 0; _i < optionsCount; _i += 1) {
                var _option = options[_i];
                optionsSize.x = max(optionsSize.x, string_width(_option.label) + optionsBorder.left + optionsBorder.right);
                optionsSize.y = max(optionsSize.y, string_height(_option.label) + optionsBorder.top + optionsBorder.bottom);
            }

            if (!is_undefined(description)) {
                optionsSize.x = max(optionsSize.x, string_width(description));
                optionsSize.y = max(optionsSize.y, string_height(description));
            }

            draw_set_font(-1);
        #endregion

        #region Espaçamentos e Tamanhos
            if (is_real(_margin)) {
                margin.left = _margin;
                margin.right = _margin;
                margin.top = _margin;
                margin.bottom = _margin;
            } else if (is_array(_margin)) {
                if (array_length(_margin) == 4) {
                    margin.left = _margin[0];
                    margin.right = _margin[1];
                    margin.top = _margin[2];
                    margin.bottom = _margin[3];
                } else if (array_length(_margin) == 2) {
                    margin.left = _margin[0];
                    margin.right = _margin[0];
                    margin.top = _margin[1];
                    margin.bottom = _margin[1];
                }
            }

            if (is_real(_padding)) {
                padding.left = _padding;
                padding.right = _padding;
                padding.top = _padding;
                padding.bottom = _padding;
            } else if (is_array(_padding)) {
                if (array_length(_padding) == 4) {
                    padding.left = _padding[0];
                    padding.right = _padding[1];
                    padding.top = _padding[2];
                    padding.bottom = _padding[3];
                } else if (array_length(_padding) == 2) {
                    padding.left = _padding[0];
                    padding.right = _padding[0];
                    padding.top = _padding[1];
                    padding.bottom = _padding[1];
                }
            }

            if (isHorizontal) {
                width = optionsSize.x * optionsCount;
                height = optionsSize.y;
            } else {
                width = optionsSize.x;
                height = optionsSize.y * optionsCount;
            }

            if (!is_undefined(description)) {
                height += optionsSize.y;
            }

            if (padding.left < 0 && padding.right < 0) {
                padding.left = (view_get_wport(0) - width) div 2;
                padding.right = (view_get_wport(0) - width) div 2;
            } else if (padding.left < 0) {
                padding.left = (view_get_wport(0) - width - padding.right);
            } else if (padding.right < 0) {
                padding.right = (view_get_wport(0) - width - padding.left);
            }

            if (padding.top < 0 && padding.bottom < 0) {
                padding.top = (view_get_hport(0) - height) div 2;
                padding.bottom = (view_get_hport(0) - height) div 2;
            } else if (padding.top < 0) {
                padding.top = (view_get_hport(0) - height - padding.bottom);
            } else if (padding.bottom < 0) {
                padding.bottom = (view_get_hport(0) - height - padding.top);
            }

            widthFull = width + padding.left + padding.right;
            heightFull = height + padding.top + padding.bottom;

            if (margin.left < 0) {
                margin.left = x;
            }

            if (margin.right < 0) {
                margin.right = view_get_wport(0) - (x + widthFull);
            }

            if (margin.top < 0) {
                margin.top = y;
            }

            if (margin.bottom < 0) {
                margin.bottom = view_get_hport(0) - (y + heightFull);
            }
        #endregion

        if (!is_undefined(_on_create)) {
            _on_create(self);
        }
    }

    return _menuInstance;
}
