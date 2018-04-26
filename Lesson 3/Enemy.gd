extends "res://Actor.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func actorType():
	return "Monster"

func think():
	var horz = (randi() % 3) - 1;
	var vert = (randi() % 3) - 1;
	
	if horz != 0:
		vert = 0;
	
	if horz != 0 || vert != 0:
		move(horz, vert)

func onHit(type, xpos, ypos):
	if type == ACTOR:
		if Game.getActorAt(xpos,ypos).actorType() == "Player":
			var anim = get_node("Sprite/Animations")
			anim .play("Attack")
			if get_node("Strong") == null:
				Game.decreasePlayerFood(10)
			else:
				Game.decreasePlayerFood(20)
			Game.finishTurn(self)
			return false

	return false