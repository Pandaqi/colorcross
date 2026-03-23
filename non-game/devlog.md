# Colorcross (Devlog)

Welcome to this short diary / developer's log about my educational puzzle game _Colorcross_. As usual, I'll try to explain how the game was made, some interesting problems I faced, and some lessons learned. It can get a bit technical at points, but I try to keep it simple and accessible. If you are a teacher or parent hoping to use these educational puzzle games, this might give some insight into the how and why behind these projects.

## What's the idea?

I already made two puzzle games about recognizing and matching colors. I still wanted to make at least one puzzle game about _mixing_ colors.

And so the following idea came to me.

* The puzzle is a small grid of squares.
* Some squares have a "collectible" (could be a treasure, an animal, a dinosaur, whatever)
* Every "move", you get a color and you simply **tap one square**.
  * This recolors all squares in the same row/column to that color!
  * If the square already had a color, of course, it **mixes the two**!
* If a square's color matches its collectible, it is collected.

Your goal is obviously to collect everything with the few moves/colors you're given.

This is definitely a step up from the previous puzzle games, but I thought it was still absolutely playable by young kids. All you do is _tap one thing_. Everything else happens automatically, visually, using that one simple rule. Your first few puzzles can be a tiny tiny grid to make it easy and accessible.

## How do we make that?

I want to _randomly generate_ the puzzles. (Instead of making each level by hand, which you'd do for more involved puzzles.)

How do we do that? Like with my earlier puzzle games, the simplest algorithm is just to ...

* Take some number of random turns
* Then pretend, once done, that those turns were the _solution_ to the puzzle all along!

More specifically,

* Start with an empty grid.
* Repeat the following.
  * Pick a random square and color to "tap"
  * Recolor all squares in the same row and column.
  * Now, randomly, **place** a collectible on a few of those squares, with its **current color**.
  * (We're just pretending the collectible was there all along, and we collected it with this fine move we just did.)

When done, we have collectibles in random colors, and we have a solution that's guaranteed to get them all.

This is simple and fast, which is one of the reasons I picked this idea over my other puzzle game ideas.

## A "puzzle framework"

Whenever you create multiple projects of a similar type (e.g. puzzle games), you start to see patterns and pieces of code you need multiple times. When that happens, I try to make those pieces of code part of a general "framework" that I can drop into any puzzle game and reuse.

It's quite overwhelming to try and make such a framework completely in one go, from scratch. I've learned to just add to it, step by step, with each new project I make. Because each new project reveals some _new thing_ I want in the framework, and gives me a reason to add it.

In this case, I added

* **Do / Undo!** Quite a crucial feature for puzzles. Also very useful when checking my code for errors, as it allows me to step through the puzzle solution.
* **No more duplicate code!** Thanks to the do/undo system, I only need to write my puzzle logic _once_ now. Both "randomly generating" the puzzle and "actually playing" the puzzle can use the exact same code.
* **Grids!** I added some generic code to instantly create a nice grid of size X, plus some other features (such as "give me this row/column")

## Technical Explanation

_Skip this if you have no experience programming._

### Do/Undo

Especially the do / undo is interesting to talk about. I'm lucky that I already learned how to do that years ago. Back then, it took me quite some time to wrap my head around it, but once you see the logic you can implement it anywhere in 10 minutes.

How does it work?

* **Every action** in your (puzzle) game is a **command**. 
* That is, you create a new class/file for each command, in which you write two functions.
  * `do()` => code to execute when you _do the thing_.
  * `undo()` => code to execute when you _undo the thing_.
* For example, when you tap the grid, I create a `CommandRecolor`. 
  * `do()` has a bit of code to get the row in the grid, and change the color of those cells. It saves all cells it changed.
  * `undo()` it simply loops through all cells it changed before and _removes_ the color again.
* Whenever the puzzle does something, the command is executed and stored, so I can undo it by just going through the history of commands in reverse.

A game like this only has 4 commands, each with only ~5 lines of code. But more complex games (like I made years ago) can have twenty or thirty intricate commands by the end.

### Practical Tips

Most importantly, I've learned three useful tricks for how to do this.

* Commands can **remember what they did**. You are _certain_ that the `do()` has been called before the `undo()` will be called. So you can remember some of the things you did to make undoing possible or faster. Just store a few more variables in that command.
* Commands can **create other commands**. For example, my `CommandTurn` (tap a square) creates two `CommandRecolor` commands (one for row, one for column). It does nothing else; it's just a nice way to put other commands into action.
* Give a **single argument** to all commands: the `CommandManager`. This one has the entire history of commands, but you also require a reference to this to create new commands (from inside other commands). Giving multiple arguments to every `do()`/`undo()` is just messy and lots of typing for no benefit.

{{% remark %}}
Sometimes it may seem like it's not possible to cleanly do some specific thing in this system. I've learned, though, that you can usually solve that with the second bullet point. Instead of putting logic inside some other class or script, always make it a _command_. Because now any command can just spawn those other commands, and because it has a reference to the CommandManager, it can pass on that reference and everyone is happy.
{{% /remark %}}

Yes, this also means my CommandManager is _not_ a Global/Singleton/Autoload (however you call it). Whenever possible, I avoid Global scripts, because they are prone to all sorts of errors. This also easily allows multiple undo histories to exist at the same time---such as one for _generating the puzzle_ and one for _playing_.

I have not encountered a situation yet in which this system does not easily allow full doing and undoing of any logic. Then again, I haven't made that many big complicated (puzzle) games.

### Seperate Data From Visuals

A key element in making this system very straightforward is the fact that my _data/logic_ and _visuals_ are completely separated.

Why? This allows the undo system to simply change a few numbers immediately ("behind the scenes"). The visuals then simply "refresh", perhaps using an animation or some delay, to match this new state.

While generating, the visuals are just _not present_, which means the algorithm can crunch the numbers quickly and without wasting time. While playing, this allows the "undo" to put the puzzle in whatever state, and the visuals will just follow their lead.

How is this done in practice?

* The data is a specific class/object (say `CellData`). It holds the color of the cell, the collectibles on it, etcetera. It does _not_ show any of that or contain any other gameplay logic.
* The visuals are handled by a different class/object (say `CellVisual`). Once I have my puzzle, I simply create that visual node for every `CellData`, and give the data as reference.
* The `CellData` has a _signal_ that it emits whenever it _changes_. The `CellVisual` listens to that, and then, upon change, refreshes what it looks like.

After many years I've found this to be the cleanest approach. I rarely encounter any errors/bugs at all like this, no matter how complicated the puzzle or the visuals. I can turn visuals on/off when debugging, I can step through the generation at any point, etcetera.

Yes, at first, it might feel a bit silly to spread the same thing (one grid `Cell`) over two scripts. I certainly felt that way years ago, because you do end up writing some extra duplicate code to make the two parts communicate. But in reality, the two parts _ARE different_! What something _is/does_ and what it _looks like/sounds like_ in a video game are just two different things. Just like someone else wearing your clothes doesn't suddenly make them _you_.


## Mixing Colors

Mixing colors seems quite straightforward. We have our nice color wheel, so we could just ...

* Get the **hue** of both colors
* Then get the **average** (the hue in-between the two)

The issue, however, is ... that it's a wheel. A circle. Which means you have _two_ averages: one clockwise and one counter clockwise. 

So I need to check which of the two distances is _smaller_. That's the one we actually care about. Otherwise, mixing red and yellow would go _the other way_ around the color wheel and somehow output that RED + YELLOW = BLUE ;)

That works and allows mixing _any_ colors, but it's far too difficult. Can anyone see the difference between two slightly different shades of red that accurately? Is that _fun_ in a puzzle game? No, especially not an educational one.

So I limited it to just 9 colors. The primary, secondary and tertiary ones. 

* Each one has a simple number (RED = 0, ORANGE = 1, etc). 
* After getting the average (which might be, say, `1.5`), we _round_ it to the nearest integer. 

This is technically not completely accurate. But it's close enough and makes mixing and recognizing colors far simpler.

## Higher Difficulties

That's it, really. Once you've taken all your moves, the game checks if any collectible is left. If not, you've solved it!

We can increase the difficulty by just making the grid bigger, allowing more colors, and requiring more moves.

We can make puzzles more interesting (less predictable/obvious) if we prefer placing collectibles on squares that have the biggest history (most colors mixed before now). This is done by _sorting_ the cells based on that property and picking those at the end.

We can make puzzles easier to understand and play if we only allow the player to place _primary colors_. This makes it easier to reason about what the mixing will do and just makes the experience nicer.

As I tried my puzzles, however, I noticed one other factor that's holding it back: 

> That every cell only has a **single** collectible (at most).

This makes the puzzles quite obvious sometimes. And once you've collected that one thing, the cell _doesn't matter at all anymore_ for the rest of the solution.

So I updated the code to allow multiple collectibles per cell. This will not be part of the easy levels, of course, only harder ones.

## These Difficulty Settings Matter A Lot

At first, I mostly scaled the numbers for every difficulty level. Next difficulty? Grid gets an extra row, a few more collectibles are placed, and so forth.

This works fine for the most part. It provides a solid "base level" for a difficulty. But when I played, I noticed a clear issue: 

> The "hardest" difficulty was often EASIER than "medium" or "hard"!

How? Why? It has a bigger grid, more moves to make, more colors, and more collectibles!

At first, I thought I had to improve my generation algorithm. The algorithm I described finds _a_ solution, but not necessarily the most efficient one. This meant that many of the "Hardest" puzzles gave you 8 moves ... while you could also do it in 4. Yes, the 8 moves version would have been "hard", but now you could quite easily see the 4-move version and be bored!

So I wrote a script that tries all moves. (A "recursive backtracker" that simply executes that Command for every cell, checks if we're at a solution, then undoes it.) It was able to find those "shorter solutions" (if they exist). If so, I discard the puzzle and just generate a new one.

There was just one problem. A big one: it was _way too slow_. It took 5--10 seconds to try all these moves and give a definitive answer about whether my solution was the shortest possible one. This was simply unusable.

{{% remark %}}
That's why, in the future, I want to switch to writing this logic in "Rust". That's a much faster programming language than the default one in my game engine. Logic like this will be 1000x faster. It sounds extreme, but I know this for sure, because I've actually written it before and tested it. But Rust is also a bit harder to understand, so if at all possible, I want to stick to my current language for puzzle games that can work with it.
{{% /remark %}}

Usually, in such cases, I've learned to actually _solve the problem_ instead of try brute-force band-aid solutions like this.

What's the problem? The harder difficulties are actually easier.

Why? Because the numbers aren't scaling _properly_!

* The grid turns from 4x4 to 5x5. (A 1.56x increase. Or, 9 extra cells.)
* But the number of moves went from 5--7 to 6--12. (Almost a 2x increase. 5--7 means it's a _range_: at least 5 moves, at most 7.)
* While the number of collectibles to grab went from 5--7 to 6--9. (A ~1.25x increase.)

This means puzzles had much more space and freedom, while you had fewer things to grab (and thus fewer constraints/meaningful turns), making it easier! 

I changed the numbers to ...

* Scale the grid less: only 4x4 -> 5x4
* Bring the number of moves _way down_ (beyond 7 or 8 moves, the puzzles don't get more interesting to play, they just get more annoying/repetitive)
* While bringing the number of collectibles _way up_. Not only do they need to stay in sync with the grid, they need to go up _more_, because _that_ is what actually makes the puzzle harder. (Now you need to collect _more things_ while having less freedom/space/moves.)

Now the harder puzzles were both _actually harder_ and _correct_ (it's rare that you can find a shorter solution). Now I could turn off my excruciatingly slow backtracking algorithm and call the game finished.

The point here is that a puzzle/game idea won't automatically work with any set of numbers. It won't even work by just scaling all numbers _equally_. To actually make it _harder_, for example, one or more numbers likely need to scale _more_ than others. Whenever your puzzle does not seem to be working, look for the actual _cause_ and try to balance those numbers or logical steps, instead of trying a band-aid complicated algorithm that's too slow ;)

{{% remark %}}
Not-So-Fun-Fact: While making this game, all my illustrations / exported images SOMEHOW became half their size. I'd draw a treasure chest in 256x256 pixels ... and it would end up 128x128 pixels within the game! I was pulling my hair out, completely confused, unable to find the cause. I just exported everything at even BIGGER sizes, which is why this game's files are polluted by files like `treasure-chest@x1.png`, `treasure-chest@x2.png`, `treasure_chest@x4.png`, and so forth.

Only days later, while finishing the next puzzle game, did I discover the cause. For SOME REASON my drawing software had changed the resolution of all projects to `144dpi` instead of the usual `72dpi`. So, everything I drew was considered "double resolution", which means the raw file size when exported was automatically cut in _half_. Ugh. Always happens to me. Anyway, fixed that, won't happen again. I hope.
{{% /remark %}}

## Conclusion

This ... is just a really strong puzzle? I was surprised about how hard this is to solve on your first try :p Even with tiny grids and few steps, I found myself undoing quite a bit before I had some Eureka about how to do it. In fact, the puzzle does not really benefit from just making things bigger. A grid size of 3x3, 4x4, 5x5 is all you really need.

I'm obviously very happy with that. It's exactly why I started doing this: to show the world that not only _can_ all education be done through games/puzzles/etc, you can do it through games that are actually interesting and fun for all ages (instead of an "educational game" that's just another boring textbook/lecture but with flashy animations).

The only "downside" is that this algorithm does not guarantee uniqueness. There will usually be two or three ways to solve it, or maybe even a shorter solution (though that's very rare on larger puzzles). But, well, I don't expect 4-year-olds to be puzzle purists who will get enraged by that ;)

Until the next devlog,

Pandaqi