import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Weather;

// Weather icons for the date block.
// Garmin gives a watch face the condition as an enum (Weather.CONDITION_*) and the temperature,
// but no icon graphics, so the 7 little icons are drawn here and every CONDITION_* is grouped by name.
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

    function drawCloud(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 4, y + 1, 4);
        dc.fillCircle(x + 1, y - 2, 5);
        dc.fillCircle(x + 5, y + 2, 4);
        dc.fillRectangle(x - 6, y + 2, 13, 4);
    }

    // icon of the given kind, about 16 x 16 px, centred on x,y
    function draw(dc as Dc, x as Number, y as Number, kind as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        if (kind == SUN || kind == PARTLY) {
            var sx = (kind == SUN) ? x : x - 4;
            var sy = (kind == SUN) ? y : y - 4;
            var r = (kind == SUN) ? 4 : 3;
            dc.fillCircle(sx, sy, r);
            var rays = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]];
            for (var i = 0; i < rays.size(); i++) {
                var dx = rays[i][0];
                var dy = rays[i][1];
                dc.drawLine(sx + dx * (r + 2), sy + dy * (r + 2), sx + dx * (r + 4), sy + dy * (r + 4));
            }
            if (kind == PARTLY) { drawCloud(dc, x + 2, y + 3); }
        } else if (kind == CLOUD) {
            drawCloud(dc, x, y + 1);
        } else if (kind == RAIN) {
            drawCloud(dc, x, y - 3);
            dc.drawLine(x - 4, y + 4, x - 5, y + 8);
            dc.drawLine(x, y + 4, x - 1, y + 8);
            dc.drawLine(x + 4, y + 4, x + 3, y + 8);
        } else if (kind == SNOW) {
            drawCloud(dc, x, y - 3);
            dc.fillCircle(x - 4, y + 6, 1);
            dc.fillCircle(x, y + 8, 1);
            dc.fillCircle(x + 4, y + 6, 1);
        } else if (kind == STORM) {
            drawCloud(dc, x, y - 3);
            dc.drawLine(x + 1, y + 3, x - 2, y + 6);
            dc.drawLine(x - 2, y + 6, x + 2, y + 6);
            dc.drawLine(x + 2, y + 6, x - 1, y + 10);
        } else {
            dc.drawLine(x - 7, y - 4, x + 7, y - 4);
            dc.drawLine(x - 7, y, x + 7, y);
            dc.drawLine(x - 7, y + 4, x + 7, y + 4);
        }
        dc.setPenWidth(1);
    }
}
