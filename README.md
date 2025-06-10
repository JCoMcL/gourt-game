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
[office-level/todo.md](./level/office-level/todo.md)

[` extends Goon #TODO  I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)`](./gourts/gourt.gd)

[` @export var stack_elasticity = 0.8 #FIXME  setting this above 0.5 results in infinte-energy.`](./gourts/gourt.gd)

[` return initial.move_toward(direction * sharpness / (delta / Engine.time_scale), snappiness) - initial #TODO refactor`](./gourts/gourt.gd)

[` #TODO reimplement to be less guesswork-oriented `](./gourts/gourt.gd)

[` foot_friend.head_friend = null #BM1`](./gourts/gourt.gd)

[` func scan_for_perch(distance  float = snap_distance)  #FIXME, this only finds one match, so fails with overlapping gourts. Perhaps intersect_point would be better?`](./gourts/gourt.gd)

[` if result and result.collider is Gourt and not result.collider.head_friend  #BM1`](./gourts/gourt.gd)

[` func apply_friction(factor  Vector2, label="friction")  #FIXME I think this isn't phyiscally accurate`](./gourts/gourt.gd)

[` func stack(g  Gourt, onto  Gourt)  #BM1`](./gourts/gourtilities.gd)

[` return UP if y > 0 else DOWN #WARN untested`](./direction.gd)

[` extends CharacterBody2D #TODO  I HATE OOP I HATE OOP (inheritence need to be reworked if we want more than just CharacterBody2D to be controllable)`](./goon.gd)

[` var bounds_size = 60 #TODO this is the gourt's size, and it's a guess`](./goon.gd)

[` class_name Master #TODO  this class should be more generic  player and AI should inheret from it`](./player.gd)

[` #TODO how does input priority work exactly? Does it make this reording unneccesary?`](./player.gd)

[` print("Goodbye World!") #TODO actual game-over`](./player.gd)

