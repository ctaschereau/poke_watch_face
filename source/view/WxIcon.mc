import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Weather;

// Weather icons for the date block.
// Garmin gives a watch face the condition as an enum (Weather.CONDITION_*) and the temperature,
// but no icon graphics, so the 7 little 8x8 pixel-art icons are defined here and every CONDITION_* is grouped by name.
// Used by DatePanel.
module WxIcon {

    enum {
        SUN, PARTLY, CLOUD, RAIN, SNOW, STORM, FOG
    }

    const SUN_CONDITIONS as Array<Number> = [
        Weather.CONDITION_CLEAR, Weather.CONDITION_MOSTLY_CLEAR, Weather.CONDITION_FAIR
    ];
    const PARTLY_CONDITIONS as Array<Number> = [
        Weather.CONDITION_PARTLY_CLOUDY, Weather.CONDITION_PARTLY_CLEAR, Weather.CONDITION_THIN_CLOUDS
    ];
    const RAIN_CONDITIONS as Array<Number> = [
        Weather.CONDITION_RAIN, Weather.CONDITION_LIGHT_RAIN, Weather.CONDITION_HEAVY_RAIN,
        Weather.CONDITION_SCATTERED_SHOWERS, Weather.CONDITION_LIGHT_SHOWERS, Weather.CONDITION_SHOWERS,
        Weather.CONDITION_HEAVY_SHOWERS, Weather.CONDITION_CHANCE_OF_SHOWERS, Weather.CONDITION_DRIZZLE,
        Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN, Weather.CONDITION_FREEZING_RAIN,
        Weather.CONDITION_UNKNOWN_PRECIPITATION
    ];
    const SNOW_CONDITIONS as Array<Number> = [
        Weather.CONDITION_SNOW, Weather.CONDITION_LIGHT_SNOW, Weather.CONDITION_HEAVY_SNOW,
        Weather.CONDITION_CHANCE_OF_SNOW, Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW, Weather.CONDITION_FLURRIES,
        Weather.CONDITION_WINTRY_MIX, Weather.CONDITION_RAIN_SNOW, Weather.CONDITION_LIGHT_RAIN_SNOW,
        Weather.CONDITION_HEAVY_RAIN_SNOW, Weather.CONDITION_CHANCE_OF_RAIN_SNOW,
        Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW, Weather.CONDITION_SLEET, Weather.CONDITION_ICE_SNOW,
        Weather.CONDITION_ICE, Weather.CONDITION_HAIL
    ];
    const STORM_CONDITIONS as Array<Number> = [
        Weather.CONDITION_THUNDERSTORMS, Weather.CONDITION_SCATTERED_THUNDERSTORMS,
        Weather.CONDITION_CHANCE_OF_THUNDERSTORMS, Weather.CONDITION_TORNADO, Weather.CONDITION_SQUALL,
        Weather.CONDITION_HURRICANE, Weather.CONDITION_TROPICAL_STORM
    ];
    const FOG_CONDITIONS as Array<Number> = [
        Weather.CONDITION_FOG, Weather.CONDITION_MIST, Weather.CONDITION_HAZY, Weather.CONDITION_HAZE,
        Weather.CONDITION_WINDY, Weather.CONDITION_DUST, Weather.CONDITION_SMOKE, Weather.CONDITION_SAND,
        Weather.CONDITION_SANDSTORM, Weather.CONDITION_VOLCANIC_ASH
    ];
    // everything else (cloudy, mostly cloudy, unknown) -> CLOUD

    // One 8x8 tile per icon, drawn at 2x (16x16 px, same grid as the pixel fonts and the trainer sprite).
    // 8 row masks per icon, bit 7 = leftmost pixel, a set bit = black. Order matches the enum above.
    const ICONS as Array<Array<Number> > = [
        [0x18, 0x42, 0x3C, 0xBD, 0xBD, 0x3C, 0x42, 0x18],   // SUN
        [0xA8, 0x70, 0xF6, 0x67, 0x1F, 0x1F, 0x0E, 0x00],   // PARTLY
        [0x00, 0x18, 0x3D, 0x7F, 0xFF, 0xFF, 0x7E, 0x00],   // CLOUD
        [0x38, 0x7D, 0xFF, 0x7E, 0x00, 0x49, 0x92, 0x00],   // RAIN
        [0x38, 0x7D, 0xFF, 0x7E, 0x00, 0x49, 0x00, 0x92],   // SNOW
        [0x38, 0x7D, 0xFF, 0x7E, 0x18, 0x30, 0x78, 0x10],   // STORM
        [0x00, 0xFF, 0x00, 0x7F, 0x00, 0xFE, 0x00, 0xFF]    // FOG
    ];
    const UNIT = 2;   // screen pixels per icon pixel
    const SIZE = 16;  // icon size on screen

    function kindFor(condition as Number or Null) as Number {
        if (condition == null) { return CLOUD; }
        if (SUN_CONDITIONS.indexOf(condition) >= 0) { return SUN; }
        if (PARTLY_CONDITIONS.indexOf(condition) >= 0) { return PARTLY; }
        if (RAIN_CONDITIONS.indexOf(condition) >= 0) { return RAIN; }
        if (SNOW_CONDITIONS.indexOf(condition) >= 0) { return SNOW; }
        if (STORM_CONDITIONS.indexOf(condition) >= 0) { return STORM; }
        if (FOG_CONDITIONS.indexOf(condition) >= 0) { return FOG; }
        return CLOUD;
    }

    // icon of the given kind, 16 x 16 px, centred on x,y (horizontal runs of set bits are drawn as one rectangle)
    function draw(dc as Dc, x as Number, y as Number, kind as Number) as Void {
        var rows = ICONS[kind];
        var left = x - SIZE / 2;
        var top = y - SIZE / 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        for (var r = 0; r < 8; r++) {
            var mask = rows[r];
            var c = 0;
            while (c < 8) {
                if ((mask & (0x80 >> c)) != 0) {
                    var start = c;
                    while (c < 8 && (mask & (0x80 >> c)) != 0) {
                        c++;
                    }
                    dc.fillRectangle(left + start * UNIT, top + r * UNIT, (c - start) * UNIT, UNIT);
                } else {
                    c++;
                }
            }
        }
    }
}
