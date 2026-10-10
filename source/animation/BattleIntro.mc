import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

// The Gen 1 "a battle starts" transition, played once a day when the step goal is reached:
//   1. FLASH  the screen pulses 3 times, like the Game Boy palette flash: dark -> black -> dark -> light -> white -> light
//   2. CLOSE  a black square spiral closes in from the edges to the centre (8 px tiles, like the Game Boy's 8x8 tiles)
//   3. GOAL   fullscreen, the step goal is "typed" out one character per tick, ending with "!" (e.g. 10000!)
//   4. OPEN   the spiral unwinds from the centre back out, revealing the watch face again
// It runs on its own 70 ms timer, only while it is playing (the face normally updates once a second),
// and is drawn on top of the whole face. Total length: 52 ticks = about 3.6 s.
class BattleIntro {

    hidden const TICK_MS = 70;
    hidden const FLASH_STEPS = 6;     // ticks per flash pulse (see flashLevel)
    hidden const FLASH_TICKS = 18;    // 3 pulses x FLASH_STEPS
    hidden const CLOSE_TICKS = 10;
    hidden const GOAL_TICKS = 16;     // "10000!" is typed in the first 6, the rest is the hold
    hidden const OPEN_TICKS = 8;
    hidden const GRID = 22;           // the screen is cut into GRID x GRID squares (8 px each on the 176 px screen)
    hidden const GOAL_MARGIN = 2;     // the goal text must keep this many px free on each side, else the smaller font is used

    hidden var _assets as Assets;
    hidden var _timer as Timer.Timer;
    hidden var _active as Boolean = false;
    hidden var _tick as Number = 0;
    hidden var _goal as Number = 0;

    function initialize(assets as Assets) {
        _assets = assets;
        _timer = new Timer.Timer();
    }

    // goal = the step goal shown fullscreen in the GOAL phase
    function start(goal as Number) as Void {
        _goal = goal;
        _tick = 0;
        _active = true;
        _timer.start(method(:onTick), TICK_MS, true);
    }

    // stops it (e.g. the wrist went down). Returns true if it was still playing, i.e. it was interrupted.
    function stop() as Boolean {
        _timer.stop();
        var wasActive = _active;
        _active = false;
        return wasActive;
    }

    function isActive() as Boolean {
        return _active;
    }

    // true when the whole screen is covered (black, white or the goal text), so the face does not need drawing at all
    function coversAll() as Boolean {
        if (!_active) {
            return false;
        }
        var t = _tick;
        if (t < FLASH_TICKS) {
            var level = flashLevel(t);
            return level == -2 || level == 2;
        }
        t -= FLASH_TICKS;
        if (t < CLOSE_TICKS) {
            return t == CLOSE_TICKS - 1;
        }
        t -= CLOSE_TICKS;
        return t < GOAL_TICKS;
    }

    // timer callback (public: the timer needs to reach it)
    function onTick() as Void {
        _tick += 1;
        if (_tick >= FLASH_TICKS + CLOSE_TICKS + GOAL_TICKS + OPEN_TICKS) {
            stop();
        }
        WatchUi.requestUpdate();
    }

    // draw over the finished face
    function draw(dc as Dc) as Void {
        if (!_active) {
            return;
        }
        var total = GRID * GRID;
        var t = _tick;
        if (t < FLASH_TICKS) {
            drawFlash(dc, flashLevel(t));
            return;
        }
        t -= FLASH_TICKS;
        if (t < CLOSE_TICKS) {
            drawSpiral(dc, total * (t + 1) / CLOSE_TICKS);
            return;
        }
        t -= CLOSE_TICKS;
        if (t < GOAL_TICKS) {
            drawGoal(dc, t);
            return;
        }
        t -= GOAL_TICKS;
        drawSpiral(dc, total - total * (t + 1) / OPEN_TICKS);
    }

    // ---------- 1. flash ----------
    // -2 = black, -1 = darkened (every other line black), 1 = lightened (every other line white), 2 = white
    hidden function flashLevel(tick as Number) as Number {
        var step = tick % FLASH_STEPS;
        if (step == 1) {
            return -2;
        }
        if (step == 0 || step == 2) {
            return -1;
        }
        if (step == 4) {
            return 2;
        }
        return 1;
    }

    hidden function drawFlash(dc as Dc, level as Number) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor((level < 0) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (level == -2 || level == 2) {
            dc.fillRectangle(0, 0, w, h);
            return;
        }
        for (var y = 0; y < h; y += 2) {
            dc.drawLine(0, y, w - 1, y);
        }
    }

    // ---------- 2. + 4. spiral ----------
    // Blackens the first `count` squares of a clockwise square spiral (outer ring -> centre). Each side of each ring
    // is one rectangle, so this is at most 4 x (GRID / 2) fills instead of one per square.
    hidden function drawSpiral(dc as Dc, count as Number) as Void {
        if (count <= 0) {
            return;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (count >= GRID * GRID) {
            dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
            return;
        }
        var cell = (dc.getWidth() + GRID - 1) / GRID;
        var remaining = count;
        for (var k = 0; k < GRID / 2 && remaining > 0; k++) {
            var size = GRID - 2 * k;
            var far = GRID - 1 - k;   // last row / column of this ring
            // top side, left -> right
            var n = (remaining < size) ? remaining : size;
            dc.fillRectangle(k * cell, k * cell, n * cell, cell);
            remaining -= n;
            if (remaining <= 0) { break; }
            // right side, top -> bottom
            n = (remaining < size - 1) ? remaining : size - 1;
            dc.fillRectangle(far * cell, (k + 1) * cell, cell, n * cell);
            remaining -= n;
            if (remaining <= 0) { break; }
            // bottom side, right -> left
            n = (remaining < size - 1) ? remaining : size - 1;
            dc.fillRectangle((far - n) * cell, far * cell, n * cell, cell);
            remaining -= n;
            if (remaining <= 0) { break; }
            // left side, bottom -> top
            n = (remaining < size - 2) ? remaining : size - 2;
            if (n > 0) {
                dc.fillRectangle(k * cell, (far - n) * cell, cell, n * cell);
                remaining -= n;
            }
        }
    }

    // ---------- 3. step goal ----------
    // white text on black, centred, typed out one character per tick: "1", "10", ... "10000", "10000!"
    // The fonts only have digits, so the "!" is drawn as rectangles on the font's pixel grid.
    hidden function drawGoal(dc as Dc, goalTick as Number) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var text = _goal.format("%d");
        var font = _assets.timeFont;   // 4x font: one font pixel = 4 screen pixels
        var px = 4;
        if (dc.getTextWidthInPixels(text, font) + 3 * px > w - 2 * GOAL_MARGIN) {
            font = _assets.stepFont;   // 2x font
            px = 2;
        }
        var digitsW = dc.getTextWidthInPixels(text, font);
        var fontH = dc.getFontHeight(font);
        var left = (w - (digitsW + 3 * px)) / 2;   // digits + a 1 px gap + the 2 px wide "!"
        var top = (h - fontH) / 2;

        var shown = goalTick + 1;      // characters visible so far (the "!" is the last one)
        var digits = (shown < text.length()) ? shown : text.length();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left, top, font, text.substring(0, digits), Graphics.TEXT_JUSTIFY_LEFT);
        if (shown > text.length()) {
            // bar 2 px wide x (fontH - 3 px) tall, a 1 px gap, then a 2 x 2 px square dot (px = one font pixel)
            var x = left + digitsW + px;
            dc.fillRectangle(x, top, 2 * px, fontH - 3 * px);
            dc.fillRectangle(x, top + fontH - 2 * px, 2 * px, 2 * px);
        }
    }
}
