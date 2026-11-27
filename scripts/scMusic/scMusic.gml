/// Escolhe e troca a música de fundo conforme a sala, com crossfade entre as faixas.
/// Salas da mesma área compartilham a faixa, então a música não reinicia ao passar entre elas.
/// Se houver um inimigo vivo na sala, a música de combate entra no lugar.
function MusicManager() constructor {
    FADE_MS = 1200;
    VOLUME = .5;

    current = undefined;
    voice = -1;
    fading = [];

    roomTracks = {
        room_0_0:   musNascente,
        room_0_n1:  musSombra,
        room_0_1:   musCavernas,
        room_1_0:   musCavernas,
        room_1_1:   musCavernas,
        room_2_0:   musCavernas,
        room_n1_0:  musCavernas,
        room_1_n1:  musAguaEstranha,
        room_2_n1:  musAguaEstranha,
        room_n1_n1: musSantuario,
    };

    /// Retorna se existe algum inimigo vivo na sala atual.
    /// @returns {Bool}
    static has_living_enemy = function() {
        var _found = false;
        with (oEnemy) {
            if (enemyState != ENEMY_STATE.DEAD) _found = true;
        }
        return _found;
    }

    /// Retorna a faixa que deveria tocar agora.
    /// @returns {Asset.GMSound}
    static desired_track = function() {
        if (has_living_enemy()) return musCombate;
        return roomTracks[$ room_get_name(room)] ?? musCavernas;
    }

    /// Troca para a faixa informada com crossfade.
    /// @param {Asset.GMSound} _track
    static play = function(_track) {
        if (_track == current) return;

        if (voice >= 0) {
            audio_sound_gain(voice, 0, FADE_MS);
            array_push(fading, voice);
        }

        voice = audio_play_sound(_track, 10, true, 0);
        audio_sound_gain(voice, VOLUME, FADE_MS);
        current = _track;
    }

    /// Deve ser chamado todo Step pelo controlador do jogo.
    static update = function() {
        play(desired_track());

        // Para as faixas que já terminaram o fade out.
        for (var _i = array_length(fading) - 1; _i >= 0; _i--) {
            var _v = fading[_i];
            if (!audio_is_playing(_v) || audio_sound_get_gain(_v) <= 0) {
                audio_stop_sound(_v);
                array_delete(fading, _i, 1);
            }
        }
    }
}
