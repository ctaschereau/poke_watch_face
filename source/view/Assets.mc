import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Fonts and the heart icon, loaded once and shared by the panels (memory is tight on a watch face).
// The three fonts are the Gen 1 Pokemon pixel font at different scales (see resources/fonts).
class Assets {

    var timeFont as Graphics.FontType;       // 4x - the big clock digits
    var stepFont as Graphics.FontType;       // 2x - steps, heart rate, temperature
    var stepFontSmall as Graphics.FontType;  // 1x - used when the 2x text would be too wide
    var heartIcon as WatchUi.BitmapResource; // resources/drawables/heart.png (14 x 12)

    function initialize() {
        timeFont = WatchUi.loadResource(Rez.Fonts.TimeFont) as Graphics.FontType;
        stepFont = WatchUi.loadResource(Rez.Fonts.StepFont) as Graphics.FontType;
        stepFontSmall = WatchUi.loadResource(Rez.Fonts.StepFontSmall) as Graphics.FontType;
        heartIcon = WatchUi.loadResource(Rez.Drawables.HeartIcon) as WatchUi.BitmapResource;
    }

    // the 2x font if `text` fits in maxWidth pixels, otherwise the 1x font
    function fitStepFont(dc as Dc, text as String, maxWidth as Number) as Graphics.FontType {
        if (dc.getTextWidthInPixels(text, stepFont) <= maxWidth) {
            return stepFont;
        }
        return stepFontSmall;
    }
}
