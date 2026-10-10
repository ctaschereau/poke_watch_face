PokeFace - Garmin Instinct 2 watch face
1. Install VS Code + the "Monkey C" extension (it downloads the Connect IQ SDK).
2. Open this folder, run "Monkey C: Build for Device" (product: instinct2) -> PokeFace.prg
3. Plug the watch in via USB and copy PokeFace.prg to GARMIN/APPS/
4. On the watch: hold UP > Watch Face > PokeFace.

Code layout (source/):
 PokeFaceApp.mc     - app entry point
 PokeFaceView.mc    - the watch face: creates the panels and draws them in order (no layout code of its own)
 view/              - one file per part of the screen
   DatePanel.mc     - top left: date (capitals, Gen 1 font, English/French from the string resources) + weather (pixel-art icon, temperature, pixel degree sign) + notification count (envelope) + the foe-style frame under it
   TimePanel.mc     - middle: big time + the trainer sprite to its right
   StepsPanel.mc    - bottom: heart rate (icon + number, always the big font), steps bar, "steps/goal" numbers + the player-style frame
   BatteryBar.mc    - left edge: battery level
   BattleFrame.mc   - shared helper: the Gen 1 HP-box edge (line + half-arrow + vertical line)
   Assets.mc        - the fonts and the heart icon, loaded once and shared by the panels
   Subscreen.mc     - position/size of the Instinct subscreen (where the ball lives)
   WxIcon.mc        - weather condition -> icon kind (named Weather.CONDITION_* groups) + the 8x8 pixel-art icons (drawn at 2x)
 animation/
   PokeAnimation.mc - ball/Pokemon state machine (OPEN_ODDS, OUT_SECONDS, where the Pokemon stands)
   PokeBall.mc      - draws the ball in the subscreen
   Pokemon.mc       - random pick (never the same one twice in a row) + dispatch
   Gfx.mc           - shared drawing helpers (shift, poly, blob, eye)
   sprites/         - Pikachu, Charmander, Bulbasaur, Squirtle, Eevee, Jigglypuff, Trainer: one file each
(Connect IQ compiles every .mc file under source/ recursively, so no jungle change is needed for the subfolders.)

Layout rules (why things sit where they do):
 - Everything is on a 2 px grid: the 2x pixel font, 2 px frame lines / bar outline, 2 px-high arrow rows, 8x8 icon tiles drawn at 2x, the 2x trainer.
 - The Instinct 2 shows a 176x176 display through a ROUND bezel opening (radius ~98 px around the centre). The four display
   corners are hidden, so every line and text must stay inside that circle: the frames' vertical lines are kept near
   x=14 (top box, starts at y=32) and x=146 (bottom box, ends at y=162), and the battery bar spans y=44..132.
 - Vertical rhythm: top box line at y=58, time digits y=82..106 (trainer feet on the same baseline), bottom box y=123..162.

Tweaking: each panel has its layout knobs (positions, sizes) as constants at the top of its file.
 - PokeAnimation.mc: OPEN_ODDS (how often the ball opens), OUT_SECONDS (how long the Pokemon stays out)
 - TimePanel.mc:     CENTER_X, CENTER_Y, TRAINER_GAP
 - StepsPanel.mc:    BAR_* (BAR_X = left end of the bar; keep it >= 74 so a 3-digit heart rate fits), NUMBERS_*, HR_*, HEART_*, STEPS_DIVISOR, FRAME_*
 - DatePanel.mc:     LEFT, DATE_Y, WEATHER_Y, NOTIF_*, FRAME_*  (date strings: resources/strings + resources-fre/strings)

To add a Pokemon: copy one sprite file, change the module name, add it to Pokemon.draw and bump Pokemon.COUNT.
Heart icon: resources/drawables/heart.png (14x12); notification envelope: resources/drawables/notif.png (12x9); both loaded in Assets.
Trainer: the 16x16 sprite data is drawn at 2x = 32x32 on screen (Trainer.SCALE).

Fonts (resources/fonts): the time, steps, temperature and date use the original Game Boy Pokemon (Gen 1) pixel font,
taken from the pret/pokered project and scaled with no smoothing: timefont = 4x, stepfont = 2x, stepfontsmall = 1x,
datefont = 1x with A-Z, 0-9 and the space (no accents: the French month names are written JAN FEV MAR AVR MAI JUN JUL AOU SEP OCT NOV DEC).
The number fonts only have the digits, "/" and "-" (no degree sign: the degree sign is drawn by DatePanel).
Assets.fitStepFont picks the 1x font automatically when the 2x steps numbers would run off their space.
The 1x font is also used for the notification count; the heart rate always uses the 2x font.
Steps numbers are shown in hundreds of steps (STEPS_DIVISOR in StepsPanel.mc); the bar still shows the real progress.
