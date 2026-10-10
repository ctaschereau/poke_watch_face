import Toybox.ActivityMonitor;
import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

// The watch face itself. It only wires the pieces together; each part of the screen has its own file:
//   view/DatePanel.mc   top left: date + weather
//   view/TimePanel.mc   middle: big time + trainer
//   view/StepsPanel.mc  bottom: heart rate + steps bar + steps numbers
//   view/BatteryBar.mc  left edge: battery level (blinks when low)
//   animation/          subscreen: Poke Ball + Pokemon (a sleeping Snorlax at night)
//   animation/BattleIntro.mc  the flash + spiral + "goal!" screen played once a day when the step goal is reached
class PokeFaceView extends WatchUi.WatchFace {

    hidden const KEY_GOAL_DAY = "goalDay";   // Storage: the day (midnight timestamp) the goal animation last played

    hidden var _datePanel as DatePanel;
    hidden var _timePanel as TimePanel;
    hidden var _stepsPanel as StepsPanel;
    hidden var _anim as PokeAnimation;
    hidden var _intro as BattleIntro;
    hidden var _asleep as Boolean = false;

    function initialize() {
        WatchFace.initialize();
        var assets = new Assets();
        _datePanel = new DatePanel(assets);
        _timePanel = new TimePanel(assets);
        _stepsPanel = new StepsPanel(assets);
        _anim = new PokeAnimation();
        _intro = new BattleIntro(assets);
    }

    function onEnterSleep() as Void {
        _asleep = true;
        if (_intro.stop()) {
            // the wrist went down before the animation ended: let it play again on the next wrist raise
            Storage.deleteValue(KEY_GOAL_DAY);
        }
        _timePanel.setAsleep(true);
        _anim.setAsleep(true);
    }

    function onExitSleep() as Void {
        _asleep = false;
        _timePanel.setAsleep(false);
        _anim.setAsleep(false);
    }

    function onUpdate(dc as Dc) as Void {
        _anim.advance();
        if (!_asleep) {
            checkStepGoal();
        }

        // while the screen is fully black there is no need to draw the face underneath
        if (!_intro.coversAll()) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
            dc.clear();

            var box = Subscreen.bounds();
            _datePanel.draw(dc, box);
            _timePanel.draw(dc);
            _stepsPanel.draw(dc);
            BatteryBar.draw(dc, _asleep);
            _anim.draw(dc, box);
        }
        _intro.draw(dc);
    }

    // starts the battle-intro animation the first time (each day) the face is shown with the step goal reached
    hidden function checkStepGoal() as Void {
        if (_intro.isActive()) {
            return;
        }
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var goal = info.stepGoal;
        if (steps == null || goal == null || goal <= 0 || steps < goal) {
            return;
        }
        var today = Time.today().value();
        var lastDay = Storage.getValue(KEY_GOAL_DAY) as Number or Null;
        if (lastDay != null && lastDay == today) {
            return;
        }
        Storage.setValue(KEY_GOAL_DAY, today);
        _intro.start(goal);
    }
}
