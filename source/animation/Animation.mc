import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;

// The ball / Pokemon animation: a tiny state machine that advances once per second.
class PokeAnimation {

    hidden const CLOSED = 0;
    hidden const OPENING = 1;   // ball open, nothing out yet (1 s)
    hidden const OUT = 2;       // Pokemon in front of the time

    hidden const OUT_SECONDS = 4;   // how long it stays out
    hidden const OPEN_ODDS = 15;    // ~1 chance in N each second to open

    // where the Pokemon stands (centre of its head area)
    hidden const POKE_X = 88;
    hidden const POKE_Y = 112;

    hidden var _state = 0;
    hidden var _tick = 0;
    hidden var _lastSec = -1;
    hidden var _asleep = false;
    hidden var _pokemon = -1;

    // where it looks on each second it's out: centre, left, right, centre(blink)
    hidden var _look as Array<Number> = [0, -1, 1, 0];

    function initialize() {
        Math.srand(Time.now().value());
    }

    function setAsleep(asleep) {
        _asleep = asleep;
        if (asleep) {
            _state = CLOSED;
        }
    }

    // call once per onUpdate; only actually steps when the second has changed
    function advance() {
        var now = Time.now().value();
        if (now == _lastSec) {
            return;
        }
        _lastSec = now;

        if (_asleep) {
            _state = CLOSED;
            return;
        }

        if (_state == CLOSED) {
            if (Math.rand() % OPEN_ODDS == 0) {
                _state = OPENING;
                _tick = 0;
                _pokemon = Pokemon.pick(_pokemon);   // a different one each time
            }
        } else if (_state == OPENING) {
            _state = OUT;
            _tick = 0;
        } else if (_state == OUT) {
            _tick += 1;
            if (_tick >= OUT_SECONDS) {
                _state = CLOSED;
                _tick = 0;
            }
        }
    }

    // box = subscreen [x, y, w, h]
    function draw(dc as Dc, box as Array<Number>) as Void {
        PokeBall.draw(dc, box, _state == CLOSED);
        if (_state == OUT) {
            Pokemon.draw(dc, _pokemon, POKE_X, POKE_Y, _look[_tick % 4], _tick);
        }
    }
}
