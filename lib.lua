local lib = {}

function lib:init()
    print("Loaded genocide library")
    

   

    self.EncounterTables = Kristal.getLibConfig("randomEncounters", "encounters")
    self.maxStep = Kristal.getLibConfig("randomEncounters", "maxStep")
    self.minStep = Kristal.getLibConfig("randomEncounters", "minStep")

    self.randomEncounter = 20
    --love.math.random(self.minStep, self.maxStep)

    self.TrueGenocide = false

    self.OnGenocide = true


    

    self.completedGenocide = false

self.used = true



  
end

function lib:onFootstep(chara, num)

    ez = self.EncounterTables
    Utils.hook(Savepoint, "onTextEnd", function(orig, self)

        if not self.world then return end

        for _,party in ipairs(Game.party) do
            party:heal(math.huge, false)
        end


      




        if self.simple_menu or (self.simple_menu == nil and (Game:isLight() or Game:getConfig("smallSaveMenu"))) then
            self.world:openMenu(SimpleSaveMenu(Game.save_id, self.marker))
        else
            self.world:openMenu(SaveMenu(self.marker))
            
    
        end
        --local encounterCount = #self.EncounterTables

        Game.world:startCutscene(function(cutscene)

            if #ez == 0 then

                cutscene:text("* Determination (0 Left)")

                
            else

            cutscene:text("* " .. #ez .. " LEFT")
            end
 
         end)

        
    end)

    self.randomEncounter = self.randomEncounter - 1

    if chara:includes(Player) and self.randomEncounter < 0 then

        Game.world:startCutscene(function(cutscene)
            local susie = cutscene:getCharacter("susie")
            local ralsei = cutscene:getCharacter("ralsei")
            Game.world.music:pause()

            cutscene:interpolateFollowers()
        cutscene:attachFollowers()


            Assets.playSound("alert")

            susie:setSprite("shock_right")
            ralsei:setSprite("surprised_down")

            cutscene:shakeCamera(10)
            cutscene:wait(1)

            for i = 1,4,1
            do
                cutscene:fadeOut(0)
                cutscene:wait(0.1)
                Assets.playSound("noise")
                cutscene:fadeIn(0)
                cutscene:wait(0.1)
            end

            if self.completedGenocide then
                cutscene:fadeOut(0)
                cutscene:wait(1)
                cutscene:text("But nobody came.")
                cutscene:wait(1)
                cutscene:fadeIn(1)
            else
                    Assets.playSound("tensionhorn")
                    cutscene:wait(8/30)
                    local src = Assets.playSound("tensionhorn")
                    src:setPitch(1.1)
                    cutscene:wait(12/30)
            local encounterId =  math.random( #self.EncounterTables)
            local encounter = cutscene:startEncounter(self.EncounterTables[encounterId], true)
           -- print(encounterId)
            local defeated_enemies = encounter:getDefeatedEnemies()


            local randomEncounterViolenceCheckCounter = 0
            local randomEncounterPacifistCheckCounter= 0

             violenceCheck = false
            for i = 1,#defeated_enemies,1
            do
                local done_state = defeated_enemies[i].done_state
                if (done_state == "VIOLENCED" and self.TrueGenocide) or done_state == "KILLED" or done_state == "FROZEN" then
                    randomEncounterViolenceCheckCounter = randomEncounterViolenceCheckCounter + 1
                

                end

                if done_state == "SPARED" or done_state == "PACIFIED" then
                    randomEncounterPacifistCheckCounter = randomEncounterPacifistCheckCounter + 1
                

                end

            end

            --print(randomEncounterCheckCounter)

            if randomEncounterViolenceCheckCounter < randomEncounterPacifistCheckCounter  and self.OnGenocide then
                --table.remove(self.EncounterTables, encounterId)
                cutscene:text("good route")
                self.OnGenocide = false
                end

            if randomEncounterViolenceCheckCounter == #defeated_enemies then
                table.remove(self.EncounterTables, encounterId)
                cutscene:text("removed encounter")
                end

            if type(next(self.EncounterTables)) == "nil" then
                self.completedGenocide = true
                Assets.playSound("ominous")
                --cutscene:text("Determination.")
                Game.world.music:play("cybercity_alt")

                
             end
            end

            susie:setSprite("walk")
            ralsei:setSprite("walk")


            if violenceCheck then
                --Assets.playSound("ominous")
                cutscene:wait(1.5)
            end
            Game.world.music:resume()



        end)        

        self.randomEncounter = 5
        --love.math.random(self.minStep, self.maxStep)
    end

 

end

return lib