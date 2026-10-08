import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Picks and draws one of the Pokemon sprites. To add another: write a new
// module with draw(dc, px, py, look, tick), then bump COUNT and add a case below.
module Pokemon {

    const COUNT = 6;

    // random id (0..COUNT-1), never the same as `last`
    function pick(last) {
        var n = Math.rand() % COUNT;
        if (n < 0) {
            n = -n;
        }
        if (n == last) {
            n = (n + 1) % COUNT;
        }
        return n;
    }

    // px,py: anchor point.  look: -1 left, 0 centre, 1 right.  tick: 0..3, blinks on 3.
    function draw(dc, id, px, py, look, tick) {
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
