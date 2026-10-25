# Helix in Wonderland

A browser game that teaches the [Helix](https://helix-editor.com) editor and
ten-finger typing to beginners, set in Lewis Carroll's *Alice's Adventures in
Wonderland* (1865, public domain). English and German (Swiss spelling, no ß).
Keyboards: German and Swiss QWERTZ, US QWERTY, French AZERTY.

Written in [Elm](https://elm-lang.org). Chapter 2 is ported; chapters 1, 3, 4
and 5 still live in the single-file JavaScript prototype and move over one
by one.

## Commands

```sh
npm install
npm run build    # → dist/helix-wonderland.html, one self-contained page
npm test         # unit tests, fuzz tests and chapter playthroughs
npm run review   # static checks: unused code, leftover Debug.log, simplifications
npm run format   # elm-format everything
npm run check    # all of the above except build; run before every commit
```

Open `dist/helix-wonderland.html` in a browser. There is no server and no
build step beyond that.

## How the code is organised

```
src/
  Main.elm                 the shell: settings, screens, routing between chapters
  Chapter/Contract.elm     what every chapter receives and may ask for  ← start here
  Chapter/Id.elm           the list of chapters and which ones are ported
  Chapter/Hall.elm         chapter 2 (model, update, view in one file)
  Chapter/Hall/Tiles.elm   the hall's tiles and how they are drawn
  Editor/Core.elm          a pure model of Helix: text, selection, modes, commands
  Editor/Keymap.elm        which key means which editor command
  Keyboard/Layout.elm      layouts, fingers, home row, layout detection
  Keyboard/View.elm        the colour-coded on-screen keyboard
  Texts.elm                every word the player reads, per language
  Language.elm, Settings.elm, Progress.elm, Speaker.elm
  Pixel/Sprite.elm         pixel art from text; Pixel/Sprites.elm holds the art
  Ui/                      dialog box, title card, results card, header, tarts
  Ports.elm                the only doors to JavaScript
public/index.html          page shell, CSS, and the JS side of the ports
tests/                     elm-test suites
review/                    elm-review configuration
tools/                     build script, plus offline helpers (see below)
```

### The three rules that keep it safe to change

1. **Chapters are pure and isolated.** A chapter exposes `init`, `update` and
   `view`. It can't touch ports, storage or another chapter. To make
   something happen outside itself, `update` returns
   `Chapter.Contract.Effect`s (play a sound, show a toast, flash a key,
   finish with a score) and `Main.applyEffect` carries them out. That one
   function is all the glue there is.

2. **The compiler checks the content.** `Texts` is a record, so every
   language must provide every line. Layouts, chapters, speakers and editor
   commands are custom types, so adding one makes the compiler list every
   `case` that still needs it.

3. **Time is a message.** Animation runs on `Frame milliseconds` messages,
   never on timers. Nothing can fire after its screen is gone, and tests can
   fast-forward time by sending frames.

### Adding a chapter

1. Create `src/Chapter/YourChapter.elm` with `init`, `update : Context -> Msg
   -> Model -> ( Model, List Effect )` and `view : Context -> Model ->
   Contract.View msg`. `Chapter/Hall.elm` is the template to copy.
2. Add its texts as a new record field in `Texts.elm` (both languages).
3. Mark it ported in `Chapter.Id.isPorted`.
4. In `Main.elm`, add a case to `Chapter` and to the three functions under
   `-- CHAPTERS`. The compiler will remind you.
5. Add a playthrough test like `tests/HallPlaythroughTest.elm`.

## Testing approach

- **Editor.Core** has example tests that read like Helix sessions
  (`press [ "w", "d" ]`) and fuzz tests for invariants that must hold for
  *any* text and *any* key sequence: the text keeps its final newline, the
  selection stays inside the text, `d` then `u` restores the text.
- **Keyboard.Layout** pins down fingers, home rows and layout detection for
  all four layouts.
- **Playthroughs** play a whole chapter through messages, the way a child
  would, and check the score. Refactor freely: if these pass, the chapter
  still works.

## Conventions

- German texts use Swiss spelling: `ss`, never `ß`.
- Keys are handled by the character they type (`KeyboardEvent.key`), so
  Helix commands work on every layout. Layouts only affect teaching hints.
- Saved data keys (`Chapter.Id.toKey`, `Keyboard.Layout.toKey`) must never
  change, or players lose their progress.
- Story text comes from the 1865 book or is newly written. Characters are
  drawn from the book, never from films.

## Working without package.elm-lang.org

Some sandboxes can reach GitHub and npm but not Elm's package site. Then:

```sh
python3 tools/fetch_elm_packages.py elm/core elm/browser elm/html elm/json elm/svg elm-explorations/test
python3 tools/make_elm_registry.py
```

The first clones packages at their release tags into `~/.elm`; the second
writes the package index the compiler expects. On a normal machine you never
need these.
