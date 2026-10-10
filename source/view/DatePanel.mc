import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;

// Top-left block: "Thu Oct 8" with the weather (icon + temperature) underneath,
// centred between the left edge and the subscreen, inside a foe-style battle frame.
// A tiny envelope + notification count sits right of the weather (hidden when there are no notifications).
class DatePanel {

    // ---- layout knobs (176x176 screen) ----
    hidden const TEXT_MARGIN = 8;       // the date must fit in (subscreen x - this), else a smaller font is used
    hidden const DATE_DY = -12;         // date line, relative to the vertical centre of the subscreen
    hidden const WEATHER_DY = 12;       // weather line, same reference
    hidden const ICON_W = 18;           // width reserved for the weather icon
    hidden const ICON_GAP = 4;          // gap between icon and temperature
    hidden const DIGIT_H = 14;          // height of the temperature digits (2x pixel font)
    hidden const DEGREE_R = 2;          // radius of the degree ring (drawn with a 2px pen, so 6px wide)
    hidden const DEGREE_GAP = 1;        // gap between the last digit and the degree ring
    hidden const WEATHER_DX = -6;       // weather block shifted left of centre to leave room for the notification
    // notification: envelope icon (12x9) with the count under it in the 1x pixel font
    hidden const NOTIF_RIGHT_GAP = 11;  // the notification column is centred this + 8 px left of the subscreen (was 6)
    hidden const NOTIF_TOP_DY = -11;    // top of the envelope, relative to the weather line's centre
    hidden const NOTIF_NUMBER_DY = 3;   // centre of the number, relative to the weather line's centre
    hidden const NOTIF_MAX = 99;        // counts above this are shown as this
    hidden const NOTIF_SHOW_ZERO = false; // true = keep the envelope visible with a 0
    // frame: vertical line on the left, line under the weather, arrow on the right
    hidden const FRAME_X = 8;           // left edge of the vertical line
    hidden const FRAME_TOP = 12;        // top of the vertical line
    hidden const FRAME_LINE_Y = 62;     // top of the bottom line
    hidden const FRAME_RIGHT_GAP = 12;  // the bottom line stops this far left of the subscreen

    hidden var _assets as Assets;

    function initialize(assets as Assets) {
        _assets = assets;
    }

    // box = subscreen [x, y, w, h]
    function draw(dc as Dc, box as Array<Number>) as Void {
        var cx = box[0] / 2;
        var cy = box[1] + box[3] / 2;
        drawDate(dc, cx, cy + DATE_DY, box[0] - TEXT_MARGIN);
        drawWeather(dc, cx + WEATHER_DX, cy + WEATHER_DY);
        drawNotifications(dc, box[0] - NOTIF_RIGHT_GAP - 8, cy + WEATHER_DY);
        BattleFrame.drawEdge(dc, FRAME_X, box[0] - FRAME_RIGHT_GAP, FRAME_TOP, FRAME_LINE_Y, false);
    }

    hidden function drawDate(dc as Dc, cx as Number, y as Number, maxWidth as Number) as Void {
        var d = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var text = Lang.format("$1$ $2$ $3$", [d.day_of_week, d.month, d.day]);
        var font = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(text, font) > maxWidth) {
            font = Graphics.FONT_XTINY;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // envelope with the count underneath, both centred on cx; y = centre of the weather line
    hidden function drawNotifications(dc as Dc, cx as Number, y as Number) as Void {
        var count = System.getDeviceSettings().notificationCount;
        if (count <= 0 && !NOTIF_SHOW_ZERO) {
            return;
        }
        if (count > NOTIF_MAX) {
            count = NOTIF_MAX;
        }
        dc.drawBitmap(cx - _assets.notifIcon.getWidth() / 2, y + NOTIF_TOP_DY, _assets.notifIcon);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y + NOTIF_NUMBER_DY, _assets.stepFontSmall, count.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // [icon] [temperature]° centred on cx
    hidden function drawWeather(dc as Dc, cx as Number, y as Number) as Void {
        var text = "--";
        var kind = WxIcon.CLOUD;
        if (Toybox has :Weather) {
            var cc = Weather.getCurrentConditions();
            if (cc != null) {
                if (cc.temperature != null) {
                    var t = cc.temperature;
                    if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
                        t = t * 9.0 / 5.0 + 32.0;
                    }
                    text = t.toNumber().format("%d");
                }
                kind = WxIcon.kindFor(cc.condition);
            }
        }

        // the pixel font has no degree glyph, so the ring is drawn right after the number
        var textW = dc.getTextWidthInPixels(text, _assets.stepFont);
        var degreeW = 2 * (DEGREE_R + 1);
        var totalW = ICON_W + ICON_GAP + textW + DEGREE_GAP + degreeW;
        var left = cx - totalW / 2;
        var textLeft = left + ICON_W + ICON_GAP;

        WxIcon.draw(dc, left + ICON_W / 2, y, kind);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(textLeft, y, _assets.stepFont, text,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // ring aligned with the top of the digits
        var ringX = textLeft + textW + DEGREE_GAP + DEGREE_R + 1;
        var ringY = y - DIGIT_H / 2 + DEGREE_R + 1;
        dc.setPenWidth(2);
        dc.drawCircle(ringX, ringY, DEGREE_R);
        dc.setPenWidth(1);
    }
}
