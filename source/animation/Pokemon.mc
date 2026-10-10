import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// Picks and draws one of the Pokemon sprites (animation/sprites/). To add another: copy a sprite file,
// change the module name, then bump SHAPE_COUNT and add a case in draw() below.
module Pokemon {

    // true  = bitmap sprites (resources/drawables/poke_*.png, 4 look-around frames each) - all 7, including Gyarados
    // false = the shape-drawn Pokemon (animation/sprites/*.mc) - 6, no Gyarados
    const USE_IMAGES = true;

    const SHAPE_COUNT = 6;   // Pikachu, Charmander, Bulbasaur, Squirtle, Eevee, Jigglypuff
    const IMAGE_COUNT = 7;   // ids 0..5 as above + 6 Gyarados (bitmap only)

    function count() as Number {
        return USE_IMAGES ? IMAGE_COUNT : SHAPE_COUNT;
    }

    // random id (0..count()-1), never the same as `last`
    function pick(last as Number) as Number {
        var total = count();
        var n = Math.rand() % total;
        if (n < 0) {
            n = -n;
        }
        if (n == last) {
            n = (n + 1) % total;
        }
        return n;
    }

    // Shape-drawn version (USE_IMAGES = false).  px, py: anchor point.  look: -1 left, 0 centre, 1 right.  tick: seconds out (0..3), blinks on 3.
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
