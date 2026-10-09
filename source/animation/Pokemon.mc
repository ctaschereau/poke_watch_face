import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Picks and draws one of the Pokemon sprites (animation/sprites/). To add another: copy a sprite file,
// change the module name, then bump COUNT and add a case in draw() below.
module Pokemon {

    const COUNT = 6;

    // random id (0..COUNT-1), never the same as `last`
    function pick(last as Number) as Number {
        var n = Math.rand() % COUNT;
        if (n < 0) {
            n = -n;
        }
        if (n == last) {
            n = (n + 1) % COUNT;
        }
        return n;
    }

    // px, py: anchor point.  look: -1 left, 0 centre, 1 right.  tick: seconds out (0..3), blinks on 3.
    function draw(dc as Dc, id as Number, px as Number, py as Number, look as Number, tick as Number) as Void {
        dc.setPenWidth(2);
        if (id == 0) {
            Pikachu.draw(dc, px, py, look, tick);
        } else if (id == 1) {
            Charmander.draw(dc, px, py, look, tick);
        } else if (id == 2) {
            Bulbasaur.draw(dc, px, py, look, tick);
        } else if (id == 3) {
            Squirtle.draw(dc, px, py, look, tick);
        } else if (id == 4) {
            Eevee.draw(dc, px, py, look, tick);
        } else if (id == 5) {
            Jigglypuff.draw(dc, px, py, look, tick);
        }
        dc.setPenWidth(1);
    }
}
