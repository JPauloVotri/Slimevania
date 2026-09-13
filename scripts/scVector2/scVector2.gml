/// Estrutura Vector2 para operações comuns em vetores cartesianos.
/// @param {real} _x Componente x do vetor.
/// @param {real} _y Componente y do vetor.
function Vector2(_x, _y) constructor {
    x = _x;
    y = _y;

    static UP = new Vector2(0, -1);
    static DOWN = new Vector2(0, 1);
    static LEFT = new Vector2(-1, 0);
    static RIGHT = new Vector2(1, 0);
    static ONE = new Vector2(1, 1);
    static ZERO = new Vector2(0, 0);

    /// @desc Retorna a inclinação deste vetor.
    /// @returns {real} A variação sobre a distância, ou "elevação sobre distância" deste vetor.
    static slope = function () {
        if (x == 0) return infinity;

        return y / x;
    }

    /// @desc Retorna a magnitude do vetor, ou seja, seu comprimento.
    /// @returns {real} O comprimento deste vetor.
    static magnitude = function () {
        return sqrt(sqr(x) + sqr(y));
    }

    /// @desc Retorna uma cópia do vetor normalizada para comprimento 1.
    /// @returns {Struct.Vector2} Uma nova instância do vetor normalizado.
    static normalized = function () {
        var _lng = magnitude();

        if (_lng == 0) return new Vector2(0, 0);

        return new Vector2(x / _lng, y / _lng);
    }

    /// @desc Normaliza este vetor e sobrescreve seus valores.
    ///       Não retorna nenhum valor.
    static normalizedRW = function () {
        var _lng = magnitude();

        if (_lng != 0) {
            x = x / _lng;
            y = y / _lng;
        }
    }

    /// @desc Soma dois vetores e retorna um novo vetor resultante.
    /// @param {Struct.Vector2} _a O primeiro vetor.
    /// @param {Struct.Vector2} _b O segundo vetor.
    /// @returns {Struct.Vector2} O vetor soma.
    static add = function (_a, _b) {
        return new Vector2(_a.x + _b.x, _a.y + _b.y);
    }

    /// @desc Adiciona outro vetor a este e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    /// @param {Struct.Vector2} _a O vetor a ser somado.
    static addRW = function (_a) {
        x += _a.x;
        y += _a.y;
    }

    /// @desc Subtrai dois vetores e retorna o vetor diferença.
    /// @param {Struct.Vector2} _a O primeiro vetor.
    /// @param {Struct.Vector2} _b O segundo vetor.
    /// @returns {Struct.Vector2} O vetor diferença.
    static subtract = function (_a, _b) {
        return new Vector2(_a.x - _b.x, _a.y - _b.y);
    }

    /// @desc Subtrai um vetor deste vetor e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    /// @param {Struct.Vector2} _a O vetor a ser subtraído.
    static subtractRW = function (_a) {
        x -= _a.x;
        y -= _a.y;
    }

    /// @desc Multiplica componente a componente de _a por _b.
    ///       Equivalente a: ( _a.x * _b.x, _a.y * _b.y ).
    /// @param {Struct.Vector2} _a O primeiro vetor.
    /// @param {Struct.Vector2} _b O segundo vetor.
    /// @returns {Struct.Vector2} O vetor resultante da multiplicação componente a componente.
    static componentMultiply = function (_a, _b) {
        return new Vector2(_a.x * _b.x, _a.y * _b.y);
    }

    /// @desc Multiplica cada componente deste vetor por um outro vetor e sobrescreve o valor atual.
    ///       Equivalente a: (x * _a.x, y * _a.y).
    /// @param {Struct.Vector2} _a O vetor pelo qual será multiplicado.
    static componentMultiplyRW = function (_a) {
        x = x * _a.x;
        y = y * _a.y;
    }

    /// @desc Multiplica um vetor por um escalar e retorna um novo vetor.
    /// @param {Struct.Vector2} _a O vetor a ser multiplicado.
    /// @param {real} _s O valor escalar.
    /// @returns {Struct.Vector2} O vetor escalado.
    static scale = function (_a, _s) {
        return new Vector2(_a.x * _s, _a.y * _s);
    }

    /// @desc Escala este vetor por um valor escalar e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    /// @param {real} _s O valor escalar usado para multiplicar o vetor.
    static scaleRW = function (_s) {
        x = x * _s;
        y = y * _s;
    }

    /// @desc Arredonda cada componente para o inteiro mais próximo.
    /// @returns {Struct.Vector2} Um novo vetor com componentes arredondados.
    static rnd = function () {
        return new Vector2(round(x), round(y));
    }

    /// @desc Arredonda cada componente deste vetor e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    static rndRW = function () {
        x = round(x);
        y = round(y);
    }

    /// @desc Arredonda cada componente para baixo, em direção ao inteiro menor.
    /// @returns {Struct.Vector2} Um novo vetor com componentes arredondados para baixo.
    static flr = function () {
        return new Vector2(floor(x), floor(y));
    }

    /// @desc Arredonda cada componente deste vetor para baixo e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    static flrRW = function () {
        x = floor(x);
        y = floor(y);
    }

    /// @desc Retorna o valor absoluto de cada componente do vetor.
    /// @returns {Struct.Vector2} Um novo vetor com componentes em valor absoluto.
    static abs = function () {
        return new Vector2(abs(x), abs(y));
    }

    /// @desc Sobrescreve cada componente deste vetor com seu valor absoluto.
    static absRW = function () {
        x = abs(x);
        y = abs(y);
    }

    /// @desc Retorna o sinal de cada componente do vetor.
    /// @returns {Struct.Vector2} Um novo vetor com o sinal de cada componente.
    static sign = function () {
        return new Vector2(sign(x), sign(y));
    }

    /// @desc Sobrescreve cada componente deste vetor com seu sinal.
    static signRW = function () {
        x = sign(x);
        y = sign(y);
    }

    /// @desc Arredonda cada componente para cima, em direção ao inteiro maior.
    /// @returns {Struct.Vector2} Um novo vetor com componentes arredondados para cima.
    static cling = function () {
        return new Vector2(ceil(x), ceil(y));
    }

    /// @desc Arredonda cada componente deste vetor para cima e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    static clingRW = function () {
        x = ceil(x);
        y = ceil(y);
    }

    /// @desc Calcula o produto escalar entre dois vetores.
    /// @param {Struct.Vector2} _a O primeiro vetor.
    /// @param {Struct.Vector2} _b O segundo vetor.
    /// @returns {real} O produto escalar.
    static dot = function (_a, _b) {
        return _a.x * _b.x + _a.y * _b.y;
    }

    /// @desc Retorna o ângulo entre dois vetores, em graus.
    /// @param {Struct.Vector2} _a O primeiro vetor.
    /// @param {Struct.Vector2} _b O segundo vetor.
    /// @returns {real} O ângulo em graus.
    static angle = function (_a, _b) {
        return arctan2((_b.y - _a.y), (_b.x - _a.x)) * (180 / pi) % 360;
    }

    /// @desc Retorna um novo vetor interpolado entre _a e _b usando o fator _t.
    /// @param {Struct.Vector2} _a O vetor inicial.
    /// @param {Struct.Vector2} _b O vetor final.
    /// @param {real} _t O fator de interpolação.
    /// @returns {Struct.Vector2} O vetor interpolado.
    static lerpV2 = function (_a, _b, _t) {
        return new Vector2(lerp(_a.x, _b.x, _t), lerp(_a.y, _b.y, _t));
    }

    /// @desc Interpola este vetor entre _a e _b usando o fator _t e sobrescreve o valor atual.
    /// @param {Struct.Vector2} _a O vetor inicial.
    /// @param {Struct.Vector2} _b O vetor final.
    /// @param {real} _t O fator de interpolação.
    static lerpV2RW = function (_a, _b, _t) {
        x = lerp(_a.x, _b.x, _t);
        y = lerp(_a.y, _b.y, _t);
    }

    /// @desc Retorna a reflexão do vetor _a em torno da normal da superfície _n.
    /// @param {Struct.Vector2} _a O vetor a ser refletido.
    /// @param {Struct.Vector2} _n A normal da superfície usada como eixo de reflexão.
    /// @returns {Struct.Vector2} O vetor refletido.
    static reflect = function (_a, _n) {
        _n = _n.normalized();
        return subtract(_a, scale(_n, scale(dot(_a, _n), 2)));
    }

    /// @desc Reflete este vetor em torno da normal _n e modifica o valor atual.
    /// @param {Struct.Vector2} _n A normal da superfície usada como eixo de reflexão.
    static reflectRW = function (_n) {
        _n.normalizedRW();
        self.subtractRW(scale(_n, scale(dot(self, _n), 2)));
    }

    /// @desc Retorna um vetor rotacionado por um número de radianos.
    /// @param {Struct.Vector2} _a O vetor a ser rotacionado.
    /// @param {real} _r Quantidade de rotação, em radianos.
    /// @returns {Struct.Vector2} O vetor rotacionado.
    static rotate = function (_a, _r) {
        return new Vector2(_a.x * cos(_r) - _a.y * sin(_r), _a.x * sin(_r) + _a.y * cos(_r));
    }

    /// @desc Rotaciona este vetor em _r radianos e sobrescreve o valor atual.
    ///       Não retorna nenhum valor.
    /// @param {real} _r Quantidade de rotação, em radianos.
    static rotateRW = function (_r) {
        x = x * cos(_r) - y * sin(_r);
        y = x * sin(_r) + y * cos(_r);
    }

    /// @desc Sobrescreve este vetor com novos valores sem alocar ou desalocar memória.
    /// @param {real} _x Componente x do vetor.
    /// @param {real} _y Componente y do vetor.
    static rewrite = function (_x, _y) {
        x = _x;
        y = _y;
    }

    /// @desc Sobrescreve este vetor com novos valores sem alocar ou desalocar memória.
    /// @param {Struct.Vector2} _a O vetor com os novos valores.
    static rewriteRW = function (_a) {
        x = _a.x;
        y = _a.y;
    }

    /// @desc Cria uma cópia deste vetor em vez de uma referência ao mesmo objeto.
    /// @returns {Struct.Vector2} Uma cópia do vetor atual.
    copy = function () {
        return new Vector2(x, y);
    }
}