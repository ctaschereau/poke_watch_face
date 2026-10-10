PokeFace - Garmin Instinct 2 watch face
1. Install VS Code + the "Monkey C" extension (it downloads the Connect IQ SDK).
2. Open this folder, run "Monkey C: Build for Device" (product: instinct2) -> PokeFace.prg
3. Plug the watch in via USB and copy PokeFace.prg to GARMIN/APPS/
4. On the watch: hold UP > Watch Face > PokeFace.

Code layout (source/):
 PokeFaceApp.mc     - app entry point
 PokeFaceView.mc    - the watch face: creates the panels and draws them in order (no layout code of its own)
 view/              - one file per part of the screen
   DatePanel.mc     - top left: date + weather (icon, temperature, degree ring) + notification count (envelope) + the foe-style frame under it
   TimePanel.mc     - middle: big time + the trainer sprite to its right
   StepsPanel.mc    - bottom: heart rate (icon + number, always the big font), steps bar, "steps/goal" numbers + the player-style frame
   BatteryBar.mc    - left edge: battery level (the whole bar blinks at or below LOW_PERCENT while the watch is awake)
   BattleFrame.mc   - shared helper: the Gen 1 HP-box edge (line + half-arrow + vertical line)
   Assets.mc        - the fonts and the heart icon, loaded once and shared by the panels
   Subscreen.mc     - position/size of the Instinct subscreen (where the ball lives)
   WxIcon.mc        - weather condition -> icon kind (named Weather.CONDITION_* groups) + the icon drawing
 animation/
   PokeAnimation.mc - ball/Pokemon state machine (OPEN_ODDS, OUT_SECONDS, where the Pokemon stands)
   PokeBall.mc      - draws the ball in the subscreen
   PokeSprites.mc   - the bitmap Pokemon (4 head-bob frames each, loaded one at a time)
   Pokemon.mc       - random pick (never the same one twice in a row) + dispatch
   Gfx.mc           - shared drawing helpers (shift, poly, blob, eye)
   SleepingPokemon.mc - night mode: a sleeping Snorlax (snorlax_sleep.png) with floating Zs replaces the ball in the subscreen
   BattleIntro.mc   - the Gen 1 flash + spiral played once a day, on the first wrist raise after the step goal is reached
   sprites/         - Pikachu, Charmander, Bulbasaur, Squirtle, Eevee, Jigglypuff, Trainer: one file each
(Connect IQ compiles every .mc file under source/ recursively, so no jungle change is needed for the subfolders.)

Night mode: SleepingPokemon.mc, NIGHT_START / NIGHT_END (default 22 -> 6). The ball does not open at night.
Step-goal animation: BattleIntro.mc, FLASH_TICKS / CLOSE_TICKS / HOLD_TICKS / OPEN_TICKS (one tick = TICK_MS = 100 ms).
 It plays once per day (the day is kept in Application.Storage under "goalDay"); if the wrist goes down mid-animation it plays again next time.
Fishing trainer: Trainer.mc, ROD_* / LINE_DROP / BOBBER_R place the rod, line and bobber (drawn with lines over the 16x16 sprite).

Tweaking: each panel has its layout knobs (positions, sizes) as constants at the top of its file.
 - PokeAnimation.mc: OPEN_ODDS (how often the ball opens), OUT_SECONDS (how long the Pokemon stays out)
 - TimePanel.mc:     CENTER_X, CENTER_Y, TRAINER_GAP
 - StepsPanel.mc:    BAR_* (BAR_X = left end of the bar; keep it >= 74 so a 3-digit heart rate fits), NUMBERS_*, HR_*, HEART_*, STEPS_DIVISOR, FRAME_*
 - DatePanel.mc:     DATE_DY, WEATHER_DY, WEATHER_DX, NOTIF_* (NOTIF_RIGHT_GAP = how far left of the subscreen the envelope sits), DEGREE_*, FRAME_*

Shape-drawn vs image Pokemon: Pokemon.USE_IMAGES (top of animation/Pokemon.mc). true = bitmaps from resources/drawables/poke_<name>_<1-4>.png
(Pikachu, Charmander, Bulbasaur, Squirtle only; frames = Head Bob animation, one per second), false = the shape-drawn ones (all 6).
The bitmaps are 1-bit with a transparent background; grey areas are dithered. Position: SPRITE_X / SPRITE_BOTTOM in PokeAnimation.mc.

To add a Pokemon: copy one sprite file, change the module name, add it to Pokemon.draw and bump Pokemon.COUNT.
Heart icon: resources/drawables/heart.png (14x12); notification envelope: resources/drawables/notif.png (12x9); both loaded in Assets.
Trainer: the 16x16 sprite data is drawn at 2x = 32x32 on screen (Trainer.SCALE).

Fonts (resources/fonts): the time, steps and temperature numbers use the original Game Boy Pokemon (Gen 1) pixel font,
taken from the pret/pokered project and scaled with no smoothing: timefont = 4x, stepfont = 2x, stepfontsmall = 1x.
The font only has the digits, "/" and "-" (no degree sign: the degree ring is drawn by DatePanel).
Assets.fitStepFont picks the 1x font automatically when the 2x steps numbers would run off their space.
The 1x font is also used for the notification count; the heart rate always uses the 2x font.
Steps numbers are shown in hundreds of steps (STEPS_DIVISOR in StepsPanel.mc); the bar still shows the real progress.
