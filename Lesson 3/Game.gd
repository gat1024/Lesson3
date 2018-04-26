extends Node

class BoardMaker extends Node:
	var cols = 12
	var rows = 12
	
	var root
	var borderTiles = [7, 8, 10]
	var floorTiles = [14, 15, 16, 17, 18, 19, 20, 21]
	var foodTiles  = [0, 1]
	var wallTiles  = [3, 4, 5, 6, 9, 11, 12, 13]
	var places     = []
	
	func _init(arootnode, foodlow, foodhi, walllow, wallhi):
		root = arootnode
		randomize()
		initializePlaces()
		createFloorAndOuterWalls()
#		createObjectsAtRandom(foodTiles, foodlow, foodhi, root.get_node("Dynamic"))
#		createObjectsAtRandom(wallTiles, walllow, wallhi, root.get_node("Dynamic"))
#		createExit()
		pass

	func initializePlaces():
		for x in range(1, cols-1):
			for y in range(1, rows-1):
				if (x != 1 && y != 1) && (x != cols-1 && y != rows-1):
					places.push_back(Vector2(x, y))

	func createFloorAndOuterWalls():
		var fts = root.get_node("Floor")
		var ots = root.get_node("Outer")
		
		for x in range(0, cols):
			for y in range (0, rows):
				var fl = randi() % self.floorTiles.size()
				fts.set_cell(x, y, floorTiles[fl])
				
				if x == 0 || y == 0 || x == cols - 1 || y == rows - 1:
					var ot = randi() % self.borderTiles.size()
					ots.set_cell(x, y, borderTiles[ot])
		pass

	func createExit():
		var dts = root.get_node("Dynamic")
		dts.set_cell(cols-2, rows-2, 2)

	func createObjectsAtRandom(alist, min_no, max_no, where):
		var count = min_no + (randi() % (max_no - min_no + 1))
		
		for i in range(0, count):
			var place = getRandomPlace()
			var tile = randi() % alist.size()
			where .set_cell(place.x, place.y, alist[tile])
		
	func getRandomPlace():
		var index = randi() % places.size()
		var place = places[index]
		places.remove(index)
		return place

var Board
var enemyList
var food = 100
var scene
var tiles
var locs    = []
var playerFood = 100
var turnQueue = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func createMap(root):
	self.scene = root
	self.turnQueue = []
	self.tiles = root.get_node("Dynamic")
	self.Board = BoardMaker.new(root, 1, 5, 5, 9)
	self.initCollisionDetect()
	self.positionPlayer()
#	self.positionEnemies(2)
	pass

func positionPlayer():
	var player = scene.get_node("Player")
	var vec = Vector2(32 + 16, 32 + 16)
	player.set_pos (vec)
	locs[1][1] = player
	enqueueActor(player)
	
func positionEnemies(howmany):
	var enemy1 = load("res://Enemy1.tscn")
	var enemy2 = load("res://Enemy2.tscn")
	var enemies = scene.get_node("Enemies")
	var script = load("res://Enemy.gd")
	
	enemyList = []
		
	for i in range(0, howmany):
		var place = Board.getRandomPlace()
		var which = randi() % 2
		var enemy
		if which == 0:
			enemy = enemy1.instance()
		else:
			enemy = enemy2.instance()

		enemy.set_pos(Vector2(place.x * 32 + 16, place.y * 32 + 16))
		locs[place.x][place.y] = enemy
		enemies.add_child(enemy)
		enqueueActor(enemy)

func initCollisionDetect():
	locs = []
	for x in range(0, Board.cols):
		locs.append([])
		for y in range(0, Board.rows):
			locs[x].append(null)

func hasFoodAt(x,y):
	return tiles.get_cell(x,y) == 0

func hasSodaAt(x,y):
	return tiles.get_cell(x,y) == 1

func hasExitAt(x,y):
	return tiles.get_cell(x,y) == 2

func hasBreakableWallAt(x,y):
	var cell = tiles.get_cell(x,y)
	return cell == 3 || cell == 4 || cell == 5 || cell == 6 || cell == 9 || cell == 11 || cell == 12 || cell == 13

func hasBarrierAt(x,y):
	var cell = scene.get_node("Outer").get_cell(x,y)
	return cell == 7 || cell == 8 || cell == 10
	
func hasActorAt(x,y):
	return locs[x][y] != null

func getActorAt(x, y):
	return locs[x][y]

func removeActorAt(x, y):
	locs[x][y].queue_free()
	locs[x][y]= null

func removeFoodAt(x, y):
	tiles.set_cell(x, y, -1)
	
func removeSodaAt(x,y):
	tiles.set_cell(x, y, -1)
	
func removeWallAt(x,y):
	tiles.set_cell(x, y, -1)

func increasePlayerFood(amount):
	playerFood += amount

func decreasePlayerFood(amount):
	playerFood -= amount

func updateActor(actor, from, to):
	locs[from.x][from.y] = null
	locs[to.x][to.y] = actor

func enqueueActor(actor):
	turnQueue.push_back(actor)
	
func dequeueActor():
	turnQueue.pop_front()
	
func isActorTurnReady(actor):
	return turnQueue.front() == actor

func finishTurn(actor):
	if turnQueue.front() != actor:
		print("Problem! Actor finished moving is on top of queue")
	else:
		dequeueActor()
		if actor.isDefeated():
			pass
		else:
			enqueueActor(actor)