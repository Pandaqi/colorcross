


## To-Do

* GENERATION:
  * I should really prevent those "early wins" (on big "hard" puzzles) => partially the fault of my DifficultySettings though
  * When we have a set number of moves (minimum), ensure we still place something until the end.
  * (Or do we just run a brute-force check? Because of our Command system, we can just do a single BACKTRACKER, right?) => Add such functionality to the PuzzleFramework system anyway.



@SOURCE: Great website to compress WebM I record for these video games => https://www.xconvert.com/compress-webm



PuzzleFramework:

* Write some short docs on the few steps to take to _integrate the framework_ in each new game.
* Actually _save_ user settings between sessions? (And save other data, like completed puzzles/highscore/etc?)
* Even more generic tutorial support?
* Localization (both text and audio)



# DIFFICULTIES

* 3x3, no mixing, moves = 1-3, 1 collectible per cell, max collections single move is 2, collectibles is 2-4
* 3x3, mixing, moves = 2-4, 1 collectible per cell, max collections single move is 2, collectibles is 2-5
* 4x3, mixing, moves = 3-6, 1 collectible per cell, max collections single move is 4, max collectibles is 4-7
* 4x4, mixing, moves = 4-8, 2 collectibles per cell, max collections single move is 5, max collectibles is 6-10
* 5x4, mixing, moves = 7-12, 4 collectibles per cell, max collections single move is 6, max collectibles is 8-15