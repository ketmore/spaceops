--this is an enhanced and expanded version of the game created in the intro OSM tutorial for love2d
--i added: semi-dynamic space background that moves with player, a basic health system, changed sprites and theme to fit a modern interpratation of asteroids. asteroids are generated with random rotations and only generate when the player is moving forward to add immersion, a basic health and score keeping HUD, a 'boost/sprint' button (lshift)

--huge current bug: sometimes the restart button doesnt work upon death (pls help me figure it out)

--wtf does this do again?
debug = true
-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box

--BEGIN imported vars from internet that i didnt bother to deobfuscate even tho i only used them like twice
local gr, down  = love.graphics, love.keyboard.isDown
--END

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
isAlive = true
canShoot = true
score = 0
health = 4
canShootTimerMax = 0.1
canShootTimer = canShootTimerMax
--More timers
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
  
-- More images
enemyImg = nil -- Like other images we'll pull this in during out love.load function
-- More storage
enemies = {} -- array of current enemies on screen

-- Image Storage
bulletImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
--function getImageScaleForNewDimensions( image, newWidth, newHeight )
    --local currentWidth, currentHeight = image:getDimensions()
  --  return ( newWidth / currentWidth ), ( newHeight / currentHeight )
  --end
function love.load(arg)
	width,height = 200,200
	px,py	= -width,-height
	image	= gr.newImage( 'assets/spacebg.jpg' )
	w, h	= 416, 416
	sx		= 16
	sy		= sx * height / width
	quad 	= gr.newQuad( 0, 0, sx*w, sy*h, w, h )
	image:setWrap( 'repeat', 'repeat' )
	player = { x = 200, y = 410, speed = 700, img = nil }
	player.img = love.graphics.newImage('assets/ship_20.png')
	bulletImg = love.graphics.newImage('assets/bullet_orange0000.png')
	enemyImg = love.graphics.newImage('assets/asteroid_25.png')
	--local scaleX, scaleY = getImageScaleForNewDimensions( enemyImg, 1, 1 )
end
function love.update(dt)
	--Horizontal Movement
	if love.keyboard.isDown('left','a') then
		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	--px = px + speed	
	elseif love.keyboard.isDown('right','d') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	--px = px - speed	
	end
	-- Vertical movement
	if love.keyboard.isDown('up', 'w') then
		if player.y > (love.graphics.getHeight() / 2) then
			player.y = player.y - (player.speed*dt)
			--isExploring = true
		end
	elseif love.keyboard.isDown('down', 's') then
		if player.y < (love.graphics.getHeight() - 55) then
			player.y = player.y + (player.speed*dt)
		end
	end
	--Faux-dynamic movement of background (trying to bring more life to the game)
	if down("down","s") and isAlive			then py = py - (player.speed*dt) end
	if down("up","w")	and isAlive		then py = py + (player.speed*dt) end
	if down("right", "d")	and isAlive		then px = px - (player.speed*dt) end
	if down("left","a")	and isAlive	then px = px + (player.speed*dt) end
	if px < -3*width		then px = -width	end
	if px > -width			then px = -3*width	end
	if py < -2*height		then py = -height	end
	if py > -height			then py = -2*height	end
	if love.keyboard.isDown('lshift') and isAlive then player.speed = 1400 else player.speed = 700 end
	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (0.5 * dt)
	if canShootTimer < 0 then
	  canShoot = true
	end
	if love.keyboard.isDown('space', 'rctrl', 'lctrl') and canShoot and isAlive then
		-- Create some bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end
	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

	  	if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end
	
	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1.5 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		
		--ranrot = math.random(1,4)
		
		--table.insert(rngs, rng)
		randomNumber = math.random(10, 400)
		newEnemy = { x = randomNumber, y = -150, img = enemyImg, ranrot = math.random(1,4) }
		--isActive = love.keyboard.isDown('up', 'w')
		if love.keyboard.isDown('up', 'w') and isAlive 
		then isExploring = true 
		else isExploring = false 
		end
		if isExploring then
		table.insert(enemies, newEnemy)		
		end
	end
	
	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (400 * dt)
		--enemy.ranrot = nil
		--enemy.x = enemy.x + (math.random(-5,5),0,math.random(-5,5)) * dt
      
		if enemy.y > 450 and isAlive then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
			if isAlive then
			health = health - 1
		   else health = health
			end
		end
		
	end
	
	--below is a shitty attempt at making the asteroids move diagonally randomly but it makes them    shake violently instead which is cool and so ill leave it here for future reference
   --randomInt = math.random(1,20)
	--[[if randomInt <= 10 then
	   for i, enemy in ipairs(enemies) do
			enemy.x = enemy.x + (600 * dt)
		end
		else 
			for i, enemy in ipairs(enemies) do
			enemy.x = enemy.x - (600 * dt)
		   end
	end]]--
	
	
	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			health = health - 1
		else health = health
			--isAlive = false
		end
		if health == 0 then
			isAlive = false
		end
		--if not isAlive then isExploring=false end
		
		--this is the restart if statement
		if not isAlive and love.keyboard.isDown('r') then
			-- remove all our bullets and enemies from screen
			bullets = {}
			enemies = {}

			-- reset timers
			canShootTimer = canShootTimerMax
			createEnemyTimer = createEnemyTimerMax
			-- move player back to default position
			player.x = 50
			player.y = 410
			-- reset our game state
			score = 0
			isAlive = true
			--health=4
		end
	end
	
end
function love.draw(dt)
	gr.setColor( 255, 255, 255, 255 )
	gr.draw( image, quad, px, py, 0, width/w, height/h )
	gr.setColor( 255, 255, 255 )
	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
		love.graphics.print("Score:", love.graphics:getWidth()/6-50, love.graphics:getHeight()/8-10)
		love.graphics.print(score, love.graphics:getWidth()/6-50, love.graphics:getHeight()/6-10)
		love.graphics.print("Health:", love.graphics:getWidth()/2-50, love.graphics:getHeight()/8-10)
		love.graphics.print(health, love.graphics:getWidth()/2-50, love.graphics:getHeight()/6-10)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	for i, bullet in ipairs(bullets) do
	  love.graphics.draw(bullet.img, bullet.x - 4.5, bullet.y)
	end
	for i, enemy in ipairs(enemies) do
		
		love.graphics.push(dt)
		
		--love.graphics.scale(0.2, 0.2)
		love.graphics.draw(enemy.img, enemy.x, enemy.y,enemy.ranrot,1,1)
		ranrot = nil
		love.graphics.pop(dt) -- so the scale doesn't affect anything else
		
		
	end
end
