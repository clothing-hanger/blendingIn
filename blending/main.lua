function love.load()
    consoleTable = {"Press ALT+C to clear debug console.\nPress ALT+D to toggle debug console."}

    --love.window.setMode(love.window.getDesktopDimensions())

    Timer = require "timer"
    baton = require "baton"
    input = baton.new {
        controls = {
            left = {"key:d"},
            leftMiddle = {"key:f"},
            rightMiddle = {"key:j"},
            right = {"key:k"},
        }
    }

    homie = love.graphics.newImage("images/homie.png")
    homer = love.graphics.newImage("images/homer.png")
    peter = love.graphics.newImage("images/peter.png")
    frank = love.graphics.newImage("images/frank.png")
    chicken = love.graphics.newImage("images/chicken.png")
    testGraphic = love.graphics.newImage("images/blendingIn.png")
    background = love.graphics.newImage("images/bg.png")
    healthIcon = love.graphics.newImage("images/hp.png")
    comboShatter = love.graphics.newImage("images/particles/comboShatter.png")
    peterBonus = love.graphics.newImage("images/peterBonus.png")

    comboShatterParticle = love.graphics.newParticleSystem(comboShatter, 1000)
    comboShatterParticle:stop()
    comboShatterParticle:setParticleLifetime(1)
    comboShatterParticle:setSpin(0,1)
    comboShatterParticle:setEmissionRate(5)
	comboShatterParticle:setSizeVariation(1)
    comboShatterParticle:setLinearDamping(5,8)
    particleSpeed = 2000
	comboShatterParticle:setLinearAcceleration(-particleSpeed, -particleSpeed, particleSpeed, particleSpeed) -- Random movement in all directions.
	--comboShatterParticle:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency

    homerLaugh = love.audio.newSource("sounds/homerLaugh.mp3", "static")
    lucky = love.audio.newSource("sounds/lucky.mp3", "static")
    lucky:setVolume(30)


    solidFont = love.graphics.newFont("fonts/FATASSFI.TTF",100)  -- i did not type this its literally the real font name lmfao 💀💀
    lineFont = love.graphics.newFont("fonts/FATASSOU.TTF",100)
    defaultFont = love.graphics.newFont(12)
    segoe = love.graphics.newFont("fonts/SEGOEPRB.TTF",40)


    printableConsole = ""
    useConsole = true
    function initGame()
        peterBonusPos = {-1000,1} --x pos, opacity
        timeRemaining = 15
        timerTime = timeRemaining*1000
        score = 0
        combo = 0
        highestCombo = 0
        comboShatterParticle:stop()
        scoreDisplay = {score}
        curHomer = love.math.random(1,4)
        curEnemy = 1
        enemy = false
        gameoverScreen = false
        title = false
        shakeIntensity = 0
        comboDisplayValues = {1,1,50,100,{0,0,0},{1,0.647,0},{0,0,0,0.5},{1,0.647,0,0.5}} -- line size, fill size, x, y, color1, color2, color1(transparent), color2(transparent)
        comboColor = comboDisplayValues[5]
        comboColorTransparent = comboDisplayValues[7]
        health = 3
        totalHits = 0
        totalClicks = 0
        diedBy = "error- diedBy was never set"
        comboShatterX = 0
        comboShatterY = 0
        comboSizeOffset = 1
        comboSizeOffset = 0.8
        shakeIntensity = 0
    end

    highScore = 0
    gameoverScreen = false
    title = true
    diedBy = "error- diedBy was never set"


    sources = {}

    inputs = {
        "d",
        "f",
        "j",
        "k"
    }

    homiePositionsTable = {
        {180,163},
        {392,165},
        {650,150},
        {954,118}
    }

    checkInput = function(input)
        totalClicks = totalClicks + 1

        if input == curHomer then
            incrementCombo()
            pickNewHomerPos(curHomer)
        elseif input == curEnemy and not PETERFUCKINGGRIFFIN then
            doGameOver(score)
            print("hit enemy")
            diedBy = "Frank Grimes"

        else
            combo = 0
            --doComboShatter(comboDisplayValues[3]+50,comboDisplayValues[4]+50)
            comboSizeOffset = 0.8
            shakeIntensity = 0
            health = health - 1
            shakeIntensity = 0
            score = score - ((score*4)/10)
            doScoreDisplay()
            comboColor = comboDisplayValues[5]
            comboColorTransparent = comboDisplayValues[7]
            comboDisplayValues[3],comboDisplayValues[4] = 50,100
            pickNewHomerPos(curHomer)
        end
    end



    pickNewHomerPos = function(curHomerPos)
        peterPercent = love.math.random(1,50)
        enemyPercent = love.math.random(1,3)
        if peterPercent == 1 then
            PETERFUCKINGGRIFFIN = true
        else
            PETERFUCKINGGRIFFIN = false
        end
        if enemyPercent == 1 then
            if not PETERFUCKINGGRIFFIN then  -- temp fix because chicken doesnt count as enemy for some reason            how does this not make the chicken never appear???? the chicken literally still shows up
                enemy = true
            else
                enemy = false
            end
        else
            enemy = false
        end
        curHomer = love.math.random(1,4)
        while curEnemy == curHomer do
            curEnemy = love.math.random(1,4)
        end
        if curHomer == curHomerPos then
            print("Same Homer Pos Picked! rerunning pickNewHomerPos() function") -- to make sure this actually works
            pickNewHomerPos(curHomerPos)
        end
    end



    doComboShatter = function(x,y)
        comboShatterX = x
        comboShatterY = y
        comboShatterParticle:start()
        comboShatterParticle:emit(40)
        comboShatterParticle:stop()
    end

            

    
    doGameOver = function(score)
        --[[
        if score > highScore then
            highScore = math.floor(score)
        end
        gameoverScreen = true
        --]]
    end


    checkHit = function(x,y)
        print("checkHit()")
        if enemy then
            if x > homiePositionsTable[curEnemy][1] and 
            x < homiePositionsTable[curEnemy][1] + homer:getWidth() and
            y > homiePositionsTable[curEnemy][2] and
            y < homiePositionsTable[curEnemy][2] + homer:getHeight() then
                doGameOver(score)
                print("hit enemy")
                if PETERFUCKINGGRIFFIN then
                    diedBy = "Ernie the Giant Chicken"
                else
                    diedBy = "Frank Grimes"
                end
                return false
            end
        end
        if x > homiePositionsTable[curHomer][1] and 
        x < homiePositionsTable[curHomer][1] + homer:getWidth() and
        y > homiePositionsTable[curHomer][2] and
        y < homiePositionsTable[curHomer][2] + homer:getHeight() then
            print("hit target")
            return true
        else
            print("missed")
            return false
        end

    end

    doPeterBonusAlert = function()
        if lucky:tell() > 2 then
            lucky:stop()
            lucky:play()
        end
        if not lucky:isPlaying() then
            lucky:play()
        end

        if luckyTween then
            Timer.cancel(luckyTween)
        end

        luckyTween = Timer.tween(1, peterBonusPos, {[1] = 100}, "out-quad", function()
            Timer.after(0.5, function()
                Timer.tween(0.2, peterBonusPos, {[2] = 0}, "linear", function()
                    peterBonusPos[1] = -1000
                    peterBonusPos[2] = 1
                end)
            end)
        end)
    end



    incrementCombo = function()
        combo = combo+1
        comboSizeOffset = comboSizeOffset + 0.01
        shakeIntensity = shakeIntensity + 0.15
        comboTilt = -0.1
        totalHits = totalHits + 1
        if combo >= highestCombo then
            highestCombo = combo
        end
        comboDisplayValues[1] = 1.35
        comboDisplayValues[2] = 1.1
        Timer.tween(0.35, comboDisplayValues, {[1]=1}, "out-quad")
        Timer.tween(0.2, comboDisplayValues, {[2]=1}, "out-quad")
        comboDisplayValues[3],comboDisplayValues[4] = 50,100
        score = score + 10*(combo/4)
        if PETERFUCKINGGRIFFIN then 
            score = score*3
            doPeterBonusAlert()
        end
        if combo >= 35 then
           -- shakeIntensity = 5
            sizeModifier = 0.5
            comboColor = comboDisplayValues[6]
            comboColorTransparent = comboDisplayValues[8]
        elseif combo >= 25 then
            --shakeIntensity = 3
            sizeModifier = 0.3
            comboColor = comboDisplayValues[5]
            comboColorTransparent = comboDisplayValues[7]
        elseif combo >= 15 then
           -- shakeIntensity = 1
            sizeModifier = 0.1
            comboColor = comboDisplayValues[5]
            comboColorTransparent = comboDisplayValues[7]
        else
           -- shakeIntensity = 0
            sizeModifier = 0
            comboColor = comboDisplayValues[5]
            comboColorTransparent = comboDisplayValues[7]
        end
        doScoreDisplay()
    end

    doScoreDisplay = function()
        if scoreDisplayTween then
            Timer.cancel(scoreDisplayTween)
        end
        scoreDisplayTween = Timer.tween(1, scoreDisplay, {score}, "out-quad")
    end

end


function love.update(dt)
    Timer.update(dt)
    input:update()
    comboShatterParticle:update(dt)
    mouseX, mouseY = love.mouse.getX(), love.mouse.getY()


    if love.keyboard.isDown(("ralt" or "lalt"), "c") then
        consoleTable = {}
    elseif love.keyboard.isDown(("ralt" or "lalt"), "d") then
        useConsole = not useConsole

    end


    if not title and not gameoverScreen then
        if (timerTime <= 0) or (health <= 0) then
            if (timerTime <= 0) then
                diedBy = "Timer"
            elseif (health <= 0) then
                diedBy = "Health ran out"
            end
            doGameOver(score)
        end

        if input:pressed("right") then
            checkInput(4)
        elseif input:pressed("rightMiddle") then
            checkInput(3)
        elseif input:pressed("leftMiddle") then
            checkInput(2)
        elseif input:pressed("left") then
            checkInput(1)
        end


        timerTime = timerTime - (love.timer.getTime() * 1000) + (previousFrameTime or (love.timer.getTime()*1000))
        previousFrameTime = love.timer.getTime() * 1000
        comboDisplayValues[3],comboDisplayValues[4] = love.math.random((comboDisplayValues[3]-shakeIntensity),(comboDisplayValues[3]+shakeIntensity)),love.math.random((comboDisplayValues[4]-shakeIntensity),(comboDisplayValues[4]+shakeIntensity))
    end

    if title or gameoverScreen then
        if love.keyboard.isDown("space") then
            initGame()
        end
    end



    
end

function love.mousepressed(x,y)

    if title or gameoverScreen then 
        initGame()
    end
  
    if not title and not gameoverScreen then
        totalClicks = totalClicks + 1

        if checkHit(x, y) then
            incrementCombo()
            pickNewHomerPos(curHomer)


        else
            combo = 0
            comboSizeOffset = 0.8
            shakeIntensity = 0
            --doComboShatter(comboDisplayValues[3]+50,comboDisplayValues[4]+50)
            health = health - 1
            shakeIntensity = 0
            score = score - ((score*4)/10)
            doScoreDisplay()
            comboColor = comboDisplayValues[5]
            comboColorTransparent = comboDisplayValues[7]
            comboDisplayValues[3],comboDisplayValues[4] = 50,100
            pickNewHomerPos(curHomer)

        end

    end
    
end

function love.touchpressed(id, x, y)
    love.mousepressed(x,y)
end

function love.keypressed(key)
end


function love.draw()
    love.graphics.setColor(1,1,1,1)

    love.graphics.draw(background,0,0)

    if not title and not gameoverScreen then
        for i = 1,4 do
            if not enemy then
                if i ~= curHomer then
                    love.graphics.draw(homie, homiePositionsTable[i][1], homiePositionsTable[i][2])
                end
            else
                if i ~= curHomer and i ~= curEnemy then
                    love.graphics.draw(homie, homiePositionsTable[i][1], homiePositionsTable[i][2])
                end
            end

        end
        for i = 1,health do
            if i == 1 then
                love.graphics.draw(healthIcon, love.graphics.getWidth() - 75, 50)
            elseif i == 2 then
                love.graphics.draw(healthIcon, love.graphics.getWidth() - 50, 50)
            elseif i == 3 then
                love.graphics.draw(healthIcon, love.graphics.getWidth() - 25, 50)
            end
        end
        if not PETERFUCKINGGRIFFIN then
            love.graphics.draw(homer, homiePositionsTable[curHomer][1], homiePositionsTable[curHomer][2])
            if enemy then
                love.graphics.draw(frank, homiePositionsTable[curEnemy][1], homiePositionsTable[curEnemy][2])
            end
        else
            love.graphics.draw(chicken, homiePositionsTable[curEnemy][1], homiePositionsTable[curEnemy][2])
            love.graphics.draw(peter, homiePositionsTable[curHomer][1], homiePositionsTable[curHomer][2])
        end


        if combo >= 5 then
            love.graphics.push()
            love.graphics.rotate(comboTilt)
            love.graphics.scale(comboSizeOffset,comboSizeOffset)
            love.graphics.setFont(lineFont)
            love.graphics.setColor(comboColor)
            love.graphics.print(combo,comboDisplayValues[3],comboDisplayValues[4],nil,comboDisplayValues[2],comboDisplayValues[2])
            love.graphics.setFont(solidFont)
            love.graphics.setColor(comboColorTransparent)
            love.graphics.print(combo,comboDisplayValues[3],comboDisplayValues[4],nil,comboDisplayValues[1],comboDisplayValues[1])
            love.graphics.setFont(defaultFont)
            love.graphics.setColor(1,1,1,1)
            love.graphics.pop()
        end
        love.graphics.setColor(1,1,1,peterBonusPos[2])

        love.graphics.draw(peterBonus, peterBonusPos[1], 100)
        love.graphics.draw(comboShatterParticle, comboShatterX, comboShatterY)
       love.graphics.setColor(1,1,1,1)

        love.graphics.setColor(0,0,0)
        love.graphics.setFont(lineFont)

        love.graphics.print("Score: "..math.floor(scoreDisplay[1]),10,70,nil,0.5)
        love.graphics.printf(math.floor(timerTime/1000),0,70,love.graphics.getWidth()-10,"right")


    end

    if gameoverScreen then
        love.graphics.setFont(lineFont)
        love.graphics.setColor(1,0,0,0.5)
        love.graphics.rectangle("fill",0,0,love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1,1,1,1)
        if score < 8075791209 then     --print balls if score is higher than the world population
            love.graphics.printf("lmao you suck",0,140,love.graphics.getWidth(),"center")
        else
            love.graphics.printf("balls",0,140,love.graphics.getWidth(),"center")
        end
        love.graphics.setFont(segoe)
        love.graphics.printf("High Score- "..highScore,0,250,love.graphics.getWidth(),"center")
        love.graphics.printf("Your Score- "..math.floor(score),0,300,love.graphics.getWidth(),"center")
        love.graphics.printf("Highest Combo- "..highestCombo,0,350,love.graphics.getWidth(),"center")
        love.graphics.printf("Accuracy- "..math.floor((totalHits/totalClicks)*100) .."%",0,400,love.graphics.getWidth(),"center")
        love.graphics.printf("Died By- "..diedBy,0,450,love.graphics.getWidth(),"center")


        love.graphics.printf("Press Space",-110,500,love.graphics.getWidth(),"center",nil,1.2,1.2)

        love.graphics.setFont(defaultFont)



    end

    if title then
        love.graphics.setColor(0,0,0,1)
        love.graphics.setFont(segoe)

        love.graphics.printf("Press Space",-110,500,love.graphics.getWidth(),"center",nil,1.2,1.2)
        love.graphics.setColor(1,1,1,1)

    end


    ----[[ DEBUG SHIT


    --love.graphics.draw(testGraphic, 0, 0)
    love.graphics.setColor(1,0,0) -- red so it is visible
    love.graphics.print("mouseX: "..mouseX.."\n"..
                        "mouseY: "..mouseY.."\n"..
                       -- "timerTime: "..timerTime.."\n"..
                      --  "score: "..score.."\n"..
                      --  "combo: "..combo.."\n"..
                       -- "checkHit: "..tostring(checkHit()).."\n"..
                        --"title: "..tostring(title).."\n"..
                        --"results: "..tostring(gameoverScreen).."\n"..

                        printableConsole
                        )
    love.graphics.setColor(1,1,1,1)
    --]]
end