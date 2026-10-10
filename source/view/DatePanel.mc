import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.WatchUi;

// Top-left block, laid out like a Gen 1 foe box:
//   FRI OCT 9              <- the date, capital letters in the 1x Gen 1 font (a "name line")
//   [icon] 14°   [env]     <- weather (icon + temperature), notification envelope + count on the right
//   |_____________/        <- foe-style frame (vertical line on the left, line + half-arrow at the bottom)
// Everything is left-aligned on LEFT and sits inside the Instinct's round bezel opening (the display corners are
// hidden behind it), so no line or text runs into the clipped corners.
class DatePanel {

    // ---- layout knobs (176x176 screen) ----
    hidden const LEFT = 22;             // left edge of the date and of the weather icon
    hidden const DATE_Y = 24;           // vertical centre of the date line
    hidden const WEATHER_Y = 42;        // vertical centre of the weather row (icon and digits)
    hidden const ICON_W = 16;           // weather icon width (8x8 tile at 2x)
    hidden const ICON_GAP = 4;          // gap between icon and temperature
    hidden const DIGIT_HALF_H = 6;      // the 2x digits are 12 px tall, centred on the row
    hidden const DEGREE_GAP = 2;        // gap between the last digit and the degree sign
    hidden const DEGREE_W = 6;          // the degree sign is 3x3 game pixels at 2x
    hidden const RIGHT_MARGIN = 12;     // the weather row stops this far left of the subscreen (no notification)
    // notification: envelope icon (12x9) with the count under it in the 1x pixel font
    hidden const NOTIF_RIGHT_GAP = 18;  // centre of the notification column = subscreen x - this
    hidden const NOTIF_HALF_W = 6;      // half the envelope width
    hidden const NOTIF_CLEARANCE = 4;   // free space between the weather row and the envelope
    hidden const NOTIF_TOP_DY = -10;    // top of the envelope, relative to the weather row's centre
    hidden const NOTIF_NUMBER_DY = 5;   // centre of the number, relative to the weather row's centre
    hidden const NOTIF_MAX = 99;        // counts above this are shown as this
    hidden const NOTIF_SHOW_ZERO = false; // true = keep the envelope visible with a 0
    // frame: vertical line on the left (beside the weather row), line under it, half-arrow on the right
    hidden const FRAME_X = 14;          // left edge of the vertical line
    hidden const FRAME_TOP = 32;        // top of the vertical line
    hidden const FRAME_LINE_Y = 58;     // top of the bottom line (2 px)
    hidden const FRAME_RIGHT_GAP = 12;  // the bottom line stops this far left of the subscreen

    // the date strings live in resources/strings (English) and resources-fre/strings (French): caps only,
    // because the date font has A-Z, digits and the space. Index = Gregorian day_of_week - 1 / month - 1.
    hidden const DAY_IDS = [
        Rez.Strings.Day1, Rez.Strings.Day2, Rez.Strings.Day3, Rez.Strings.Day4,
        Rez.Strings.Day5, Rez.Strings.Day6, Rez.Strings.Day7
    ];
    hidden const MONTH_IDS = [
        Rez.Strings.Month1, Rez.Strings.Month2, Rez.Strings.Month3, Rez.Strings.Month4,
        Rez.Strings.Month5, Rez.Strings.Month6, Rez.Strings.Month7, Rez.Strings.Month8,
        Rez.Strings.Month9, Rez.Strings.Month10, Rez.Strings.Month11, Rez.Strings.Month12
    ];

    hidden var _assets as Assets;
    hidden var _dateKey as Number = -1;     // yyyymmdd of the cached date text
    hidden var _dateText as String = "";

    function initialize(assets as Assets) {
        _assets = assets;
    }

    // box = subscreen [x, y, w, h]
    function draw(dc as Dc, box as Array<Number>) as Void {
        var notifCount = notificationCount();
        var showNotif = notifCount > 0 || NOTIF_SHOW_ZERO;
        var notifX = box[0] - NOTIF_RIGHT_GAP;
        var rightLimit = box[0] - RIGHT_MARGIN;
        if (showNotif) {
            rightLimit = notifX - NOTIF_HALF_W - NOTIF_CLEARANCE;
        }
        drawDate(dc);
        drawWeather(dc, WEATHER_Y, rightLimit);
        if (showNotif) {
            drawNotifications(dc, notifX, WEATHER_Y, notifCount);
        }
        BattleFrame.drawEdge(dc, FRAME_X, box[0] - FRAME_RIGHT_GAP, FRAME_TOP, FRAME_LINE_Y, false);
    }

    // ---------- date ----------
    // "FRI OCT 9" (English) / "VEN 9 OCT" (French): built from numbers + string resources so it is always capitals,
    // and cached for the day.
    hidden function dateText() as String {
        var d = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var key = (d.year as Number) * 10000 + (d.month as Number) * 100 + (d.day as Number);
        if (key != _dateKey) {
            var dayName = WatchUi.loadResource(DAY_IDS[(d.day_of_week as Number) - 1]) as String;
            var monthName = WatchUi.loadResource(MONTH_IDS[(d.month as Number) - 1]) as String;
            var format = WatchUi.loadResource(Rez.Strings.DateFormat) as String;
            _dateText = Lang.format(format, [dayName, monthName, d.day]);
            _dateKey = key;
        }
        return _dateText;
    }

    hidden function drawDate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(LEFT, DATE_Y, _assets.dateFont, dateText(),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ---------- notifications ----------
    hidden function notificationCount() as Number {
        var count = System.getDeviceSettings().notificationCount;
        if (count == null || count < 0) {
            return 0;
        }
        return (count > NOTIF_MAX) ? NOTIF_MAX : count;
    }

    // envelope with the count underneath, both centred on cx; y = centre of the weather row
    hidden function drawNotifications(dc as Dc, cx as Number, y as Number, count as Number) as Void {
        dc.drawBitmap(cx - _assets.notifIcon.getWidth() / 2, y + NOTIF_TOP_DY, _assets.notifIcon);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y + NOTIF_NUMBER_DY, _assets.stepFontSmall, count.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ---------- weather ----------
    // [icon] [temperature][degree], left-aligned on LEFT. The temperature uses the 2x font, or the 1x font
    // when it would run past rightLimit (e.g. "-12" next to the notification envelope).
    hidden function drawWeather(dc as Dc, y as Number, rightLimit as Number) as Void {
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

        var textLeft = LEFT + ICON_W + ICON_GAP;
        var maxTextW = rightLimit - textLeft - DEGREE_GAP - DEGREE_W;
        var big = dc.getTextWidthInPixels(text, _assets.stepFont) <= maxTextW;
        var font = big ? _assets.stepFont : _assets.stepFontSmall;
        var textW = dc.getTextWidthInPixels(text, font);
        // the 14 px cell of the 2x font has its 12 px digits at the top, so the cell is drawn 1 px below the row's centre
        var textY = big ? y + 1 : y;

        WxIcon.draw(dc, LEFT + ICON_W / 2, y, kind);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(textLeft, textY, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        var degreeTop = big ? y - DIGIT_HALF_H : y - 4;
        drawDegree(dc, textLeft + textW + DEGREE_GAP, degreeTop);
    }

    // degree sign in the same pixel style as the fonts: a 3x3 game-pixel ring (4 blocks of 2x2 px), x,y = top-left
    hidden function drawDegree(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x + 2, y, 2, 2);
        dc.fillRectangle(x, y + 2, 2, 2);
        dc.fillRectangle(x + 4, y + 2, 2, 2);
        dc.fillRectangle(x + 2, y + 4, 2, 2);
    }
}
