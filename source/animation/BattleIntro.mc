import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

// The Gen 1 "a battle starts" transition, played once a day when the step goal is reached:
//   1. the screen flashes black 3 times
//   2. a black square spiral closes in from the edges to the centre
//   3. a short black hold
//   4. the spiral unwinds from the centre back out, revealing the watch face again
// It runs on its own 100 ms timer, only while it is playing (the face normally updates once a second),
// and is drawn on top of the whole face. Total length: 24 ticks = 2.4 s.
class BattleIntro {

    hidden const TICK_MS = 100;
    hidden const FLASH_TICKS = 6;    // black on the even ticks (0, 2, 4), the face on the odd ones
    hidden const CLOSE_TICKS = 8;
    hidden const HOLD_TICKS = 2;
    hidden const OPEN_TICKS = 8;
    hidden const GRID = 11;          // the screen is cut into GRID x GRID squares (16 px each on the 176 px screen)

    hidden var _timer as Timer.Timer;
    hidden var _active as Boolean = false;
    hidden var _tick as Number = 0;
    hidden var _order as Array<Number>;   // the squares (row * GRID + column) in spiral order, outside -> centre

    function initialize() {
        _timer = new Timer.Timer();
        _order = buildSpiral();
    }

    function start() as Void {
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

    // true when the whole screen is black, so the face does not need drawing at all
    function coversAll() as Boolean {
        return _active && covered() >= GRID * GRID;
    }

    // timer callback (public: the timer needs to reach it)
    function onTick() as Void {
        _tick += 1;
        if (_tick >= FLASH_TICKS + CLOSE_TICKS + HOLD_TICKS + OPEN_TICKS) {
            stop();
        }
        WatchUi.requestUpdate();
    }

    // draw over the finished face
    function draw(dc as Dc) as Void {
        if (!_active) {
            return;
        }
        var count = covered();
        if (count <= 0) {
            return;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (count >= GRID * GRID) {
            dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
            return;
        }
        var cell = (dc.getWidth() + GRID - 1) / GRID;
        for (var i = 0; i < count; i++) {
            var index = _order[i];
            dc.fillRectangle((index % GRID) * cell, (index / GRID) * cell, cell, cell);
        }
    }

    // how many squares of the spiral are black on the current tick
    hidden function covered() as Number {
        var total = GRID * GRID;
        var t = _tick;
        if (t < FLASH_TICKS) {
            return (t % 2 == 0) ? total : 0;
        }
        t -= FLASH_TICKS;
        if (t < CLOSE_TICKS) {
            return total * (t + 1) / CLOSE_TICKS;
        }
        t -= CLOSE_TICKS;
        if (t < HOLD_TICKS) {
            return total;
        }
        t -= HOLD_TICKS;
        return total - total * (t + 1) / OPEN_TICKS;
    }

    // clockwise square spiral from the outer ring to the centre
    hidden function buildSpiral() as Array<Number> {
        var out = [] as Array<Number>;
        var top = 0;
        var bottom = GRID - 1;
        var left = 0;
        var right = GRID - 1;
        while (top <= bottom && left <= right) {
            for (var c = left; c <= right; c++) {
                out.add(top * GRID + c);
            }
            for (var r = top + 1; r <= bottom; r++) {
                out.add(r * GRID + right);
            }
            if (top < bottom) {
                for (var c = right - 1; c >= left; c--) {
                    out.add(bottom * GRID + c);
                }
            }
            if (left < right) {
                for (var r = bottom - 1; r > top; r--) {
                    out.add(r * GRID + left);
                }
            }
            top += 1;
            bottom -= 1;
            left += 1;
            right -= 1;
        }
        return out;
    }
}
