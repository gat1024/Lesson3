extends Node2D

# The Actor is the basis of our movement behavior for
# players and enemies.
const FOOD  = 1
const SODA  = 2
const WALL  = 3
const OUTER = 4
const ACTOR = 5
const EXIT  = 6

var isAttacking = false
var finishAttack

var isMoving = false
var isOut = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var tween = get_node("Tween")
	tween.connect("tween_complete", self, "afterMove")
	set_process(true)
	pass

func _process(delta):
	if Game.isActorTurnReady(self):
		if isOut == false:
			think()
		else:
			Game.finishTurn(self)
	pass
	
func think():
	print("Generic think()...")
	pass

func isDefeated():
	return isOut

func defeat():
	isOut = true
	
func onHit(type, xpos, ypos):
	return false
	pass
	
func move(xDir, yDir):
	if xDir == 0 && yDir == 0:
		isMoving = false
		return

	if isMoving == true:
		return
	
	var tween = get_node("Tween")
	var sprite = self
	
	var curPlace = sprite.get_pos()
	var newPlace = curPlace + Vector2(xDir*32, yDir*32)	
	var old  = Vector2 ((curPlace.x-16)/32, (curPlace.y-16)/32)
	var tile = old + Vector2(xDir, yDir)
	
	print(curPlace, " == ", old)
	
	if Game.hasFoodAt(tile.x, tile.y):
		if onHit(FOOD, tile.x, tile.y) == false:
			return
	elif Game.hasSodaAt(tile.x, tile.y):
		if onHit(SODA, tile.x, tile.y) == false:
			return
	elif Game.hasBreakableWallAt(tile.x, tile.y):
		if onHit(WALL, tile.x, tile.y) == false:
			return
	elif Game.hasBarrierAt(tile.x, tile.y):
		if onHit(OUTER, tile.x, tile.y) == false:
			return
	elif Game.hasActorAt(tile.x, tile.y):
		if onHit(ACTOR, tile.x, tile.y) == false:
			return
	elif Game.hasExitAt(tile.x, tile.y):
		if onHit(EXIT, tile.x, tile.y) == false:
			return
	
	isMoving = true
	Game.updateActor(self, old, tile)
	tween.interpolate_property(sprite, "transform/pos", curPlace, newPlace, 0.10, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	Game.finishTurn(self)
	
func afterMove(object, key):
	isMoving = false;
	
func actorType():
	return "Generic"