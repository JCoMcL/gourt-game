# Directory struture
1. Organised by object, not by filetype.
2. Organization should er on the side of flatness and focus on retrievability.
3. `.tscn` and `.gd` should generally not be sorted away since they need to be more retrievable than other assets like sprites.
4. `.tscn` and `.gd` files should have descriptive names, and should have the same name if relating to the same object.
5. File names should not contain redundant information that can be communicated by the name of their parent folder, except when observing rule no. 4

# Bug Magnets
## BM1: Gourt Neighbour References
Gourts keep track of their neighbours in the stack, however there no gaurentee that these references are correct and if they are not correct it could cause all manner if weird behaviour inlcuding startup crashes

# Misc.
addd gourts looking at things
twitch integtation
- chatters control NPCs

# See Also (auto-generated)
[office level/todo.md](./level/office level/todo.md)

[` func stack(g  Gourt, onto  Gourt)  #BM1`](./gourts/gourtilities.gd)

[` extends Goon #TODO  I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)`](./gourts/gourt.gd)

[` return Direction.UP if y > 0 else Direction.DOWN #WARN untested`](./gourts/gourt.gd)

[` #TODO reimplement to be less guesswork-oriented `](./gourts/gourt.gd)

[` foot_friend.head_friend = null #BM1`](./gourts/gourt.gd)

[` extends CharacterBody2D #TODO  I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)class_name Goon`](./goon.gd)

[` var bounds_size = 60 #TODO this is the gourt's size, and it's a guess`](./goon.gd)

[` class_name Master #TODO  this class should be more generic  player and AI should inheret from it`](./player.gd)

[` #TODO how does input priority work exactly? Does it make this reording unneccesary?`](./player.gd)

[` print("Goodbye World!") #TODO actual game-over`](./player.gd)

