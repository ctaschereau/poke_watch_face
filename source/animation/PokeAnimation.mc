import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;

// The ball / Pokemon animation: a tiny state machine that advances once per second.
class PokeAnimation {

    // states
    hidden const CLOSED = 0;    // ball closed
    hidden const OPENING = 1;   // ball open, nothing out yet (1 s)
    hidden const OUT = 2;       // Pokemon out, in front of the time

    hidden const OUT_SECONDS = 4;   // how long the Pokemon stays out
    hidden const OPEN_ODDS = 15;    // ~1 chance in N each second that the ball opens

    // where the Pokemon stands (centre of its head area)
    hidden const POKE_X = 88;
    hidden const POKE_Y = 112;

    // where the bitmap Pokemon stands (Pokemon.USE_IMAGES): bottom-centre of the sprite box
    hidden const SPRITE_X = 88;
    hidden const SPRITE_BOTTOM = 166;

    // where it looks on each second it is out: centre, left, right, centre (blink on the last one)
    hidden const LOOK as Array<Number> = [0, -1, 1, 0];

    hidden var _state as Number;
    hidden var _tick as Number;        // seconds since the Pokemon came out
    hidden var _lastSec as Number;     // last second we advanced on
    hidden var _asleep as Boolean;
    hidden var _pokemon as Number;     // id of the current Pokemon (see Pokemon.mc)
    hidden var _sprites as PokeSprites;

    function initialize() {
        _state = CLOSED;
        _tick = 0;
        _lastSec = -1;
        _asleep = false;
        _pokemon = -1;
        _sprites = new PokeSprites();
        Math.srand(Time.now().value());
    }

    function setAsleep(asleep as Boolean) as Void {
        _asleep = asleep;
        if (asleep) {
            _state = CLOSED;
            _sprites.release();
        }
    }

    // call once per onUpdate; only actually steps when the second has changed
    function advance() as Void {
        var now = Time.now().value();
        if (now == _lastSec) {
            return;
        }
        _lastSec = now;

        if (_asleep) {
            _state = CLOSED;
            _sprites.release();
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
                _sprites.release();
            }
        }
    }

    // box = subscreen [x, y, w, h]
    function draw(dc as Dc, box as Array<Number>) as Void {
        PokeBall.draw(dc, box, _state == CLOSED);
        if (_state == OUT) {
            if (Pokemon.USE_IMAGES) {
                _sprites.draw(dc, _pokemon, _tick, SPRITE_X, SPRITE_BOTTOM);
            } else {
                Pokemon.draw(dc, _pokemon, POKE_X, POKE_Y, LOOK[_tick % LOOK.size()], _tick);
            }
        }
    }
}
