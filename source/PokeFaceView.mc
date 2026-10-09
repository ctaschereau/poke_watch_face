import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// The watch face itself. It only wires the pieces together; each part of the screen has its own file:
//   view/DatePanel.mc   top left: date + weather
//   view/TimePanel.mc   middle: big time + trainer
//   view/StepsPanel.mc  bottom: heart rate + steps bar + steps numbers
//   view/BatteryBar.mc  left edge: battery level
//   animation/          subscreen: Poke Ball + Pokemon
class PokeFaceView extends WatchUi.WatchFace {

    hidden var _datePanel as DatePanel;
    hidden var _timePanel as TimePanel;
    hidden var _stepsPanel as StepsPanel;
    hidden var _anim as PokeAnimation;

    function initialize() {
        WatchFace.initialize();
        var assets = new Assets();
        _datePanel = new DatePanel(assets);
        _timePanel = new TimePanel(assets);
        _stepsPanel = new StepsPanel(assets);
        _anim = new PokeAnimation();
    }

    function onLayout(dc as Dc) as Void {
        _stepsPanel.layout(dc);
    }

    function onEnterSleep() as Void {
        _timePanel.setAsleep(true);
        _anim.setAsleep(true);
    }

    function onExitSleep() as Void {
        _timePanel.setAsleep(false);
        _anim.setAsleep(false);
    }

    function onUpdate(dc as Dc) as Void {
        _anim.advance();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();

        var box = Subscreen.bounds();
        _datePanel.draw(dc, box);
        _timePanel.draw(dc);
        _stepsPanel.draw(dc);
        BatteryBar.draw(dc);
        _anim.draw(dc, box);
    }
}
