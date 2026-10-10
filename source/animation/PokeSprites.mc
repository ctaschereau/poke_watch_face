import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// The bitmap Pokemon (used when Pokemon.USE_IMAGES is true).
// 4 head-bob frames per Pokemon: resources/drawables/poke_<name>_<1-4>.png, declared in drawables.xml as <Name>Img<1-4>.
// Pokemon ids match Pokemon.mc: 0 Pikachu, 1 Charmander, 2 Bulbasaur, 3 Squirtle, 4 Eevee, 5 Jigglypuff, 6 Gyarados.
// Only the frame being shown is kept in memory (a watch face has very little of it).
class PokeSprites {

    hidden const FRAMES = 4;

    hidden var _key as Number = -1;                      // pokemon * FRAMES + frame of the loaded bitmap
    hidden var _bitmap as WatchUi.BitmapResource? = null;

    // frame = 0..3 (one per second out: frame 1, high bob, low bob, high bob).
    // centerX / bottomY = where the bottom-centre of the sprite box stands; all frames of a Pokemon share one box,
    // so the bob shows up as movement inside it.
    function draw(dc as Dc, pokemon as Number, frame as Number, centerX as Number, bottomY as Number) as Void {
        var f = frame % FRAMES;
        var key = pokemon * FRAMES + f;
        if (key != _key) {
            _bitmap = null;                               // free the old frame before loading the next
            _bitmap = WatchUi.loadResource(idFor(pokemon, f)) as WatchUi.BitmapResource;
            _key = key;
        }
        var bmp = _bitmap;
        if (bmp != null) {
            dc.drawBitmap(centerX - bmp.getWidth() / 2, bottomY - bmp.getHeight(), bmp);
        }
    }

    // call when the Pokemon goes back in its ball
    function release() as Void {
        _bitmap = null;
        _key = -1;
    }

    hidden function idFor(pokemon as Number, frame as Number) {
        var ids = [
            [Rez.Drawables.PikachuImg1, Rez.Drawables.PikachuImg2, Rez.Drawables.PikachuImg3, Rez.Drawables.PikachuImg4],
            [Rez.Drawables.CharmanderImg1, Rez.Drawables.CharmanderImg2, Rez.Drawables.CharmanderImg3, Rez.Drawables.CharmanderImg4],
            [Rez.Drawables.BulbasaurImg1, Rez.Drawables.BulbasaurImg2, Rez.Drawables.BulbasaurImg3, Rez.Drawables.BulbasaurImg4],
            [Rez.Drawables.SquirtleImg1, Rez.Drawables.SquirtleImg2, Rez.Drawables.SquirtleImg3, Rez.Drawables.SquirtleImg4],
            [Rez.Drawables.EeveeImg1, Rez.Drawables.EeveeImg2, Rez.Drawables.EeveeImg3, Rez.Drawables.EeveeImg4],
            [Rez.Drawables.JigglypuffImg1, Rez.Drawables.JigglypuffImg2, Rez.Drawables.JigglypuffImg3, Rez.Drawables.JigglypuffImg4],
            [Rez.Drawables.GyaradosImg1, Rez.Drawables.GyaradosImg2, Rez.Drawables.GyaradosImg3, Rez.Drawables.GyaradosImg4]
        ];
        return ids[pokemon][frame];
    }
}
