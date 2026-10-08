PokeFace - Garmin Instinct 2 watch face
1. Install VS Code + the "Monkey C" extension (it downloads the Connect IQ SDK).
2. Open this folder, run "Monkey C: Build for Device" (product: instinct2) -> PokeFace.prg
3. Plug the watch in via USB and copy PokeFace.prg to GARMIN/APPS/
4. On the watch: hold UP > Watch Face > PokeFace.
Tweak: OPEN_ODDS, OUT_SECONDS, and the layout knobs (HR_LEFT, BAR_Y, BAR_H, BAR_RIGHT, STEPS_TEXT_Y, TIME_CX, TIME_MAX_W, TIME_MAX_H) at the top of PokeFaceView.mc.

Code layout (source/):
 PokeFaceView.mc  - the watch face itself: time, date, weather, steps bar + heart rate, battle-scene frame lines, battery
 WxIcon.mc        - weather condition -> icon kind (named Weather.CONDITION_* groups) + the icon drawing
 animation/
   Animation.mc   - ball/Pokemon state machine (OPEN_ODDS, OUT_SECONDS, where the Pokemon stands)
   PokeBall.mc    - draws the ball in the subscreen
   Pokemon.mc     - random pick (never the same one twice in a row) + dispatch
   Gfx.mc         - shared drawing helpers (shift, poly, blob, eye)
   sprites/       - Pikachu, Charmander, Bulbasaur, Squirtle, Eevee, Jigglypuff: one file each
To add a Pokemon: copy one sprite file, change the module name, add it to Pokemon.draw and bump Pokemon.COUNT.
(Connect IQ compiles every .mc file under source/ recursively, so no jungle change is needed for the subfolders.)
Heart icon: resources/drawables/heart.png (14x12), loaded in PokeFaceView.onLayout.

Fonts (resources/fonts): the time and the steps numbers use the original Game Boy Pokemon (Gen 1) pixel font,
taken from the pret/pokered project and scaled with no smoothing: timefont = 4x, stepfont = 2x, stepfontsmall = 1x
(used automatically when the steps numbers would run off the left side).
Steps numbers are divided by STEPS_DIVISOR (10); the bar still shows the real progress.
