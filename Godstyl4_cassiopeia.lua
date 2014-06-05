--[[
            Cassiopeia 1.0 by godstyl4
                   
            -Full combo: Items -> Q -> W -> E -> R
            -otomatik item skil kulanimi ve ignite desteği vardir, ulti için demaj hessaplayici ekledim
            -Hedef seçimini, Shift e basarak düzenleyiniz
            -Option da auto ignite ve ks yapma secemeklerini ayarlayınız
            
           
    ]]--
     
    if myHero.charName ~= "Cassiopeia" then return end
     
    --[[            Code            ]]
    local range = 850
    local erange = 700
    -- Active
    local poisonedtimets = 0
    local poisonedtime = {}
    -- draw
    local waittxt = {}
    local floattext = {"Becerileri mevcut degildir","Mucadele et","Killable","Onu Oldur!"}
    local killable = {}
    local calculationenemy = 1
    -- ts
    local ts
    --
    local ignite = nil
    local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
    local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false, false
     
    function OnLoad()
            PrintChat(" >> Cassiopeia 1.0 Godstyl4 loaded!")
            CassiopeiaConfig = scriptConfig("Cassiopeia Godstyl4", "cassiopeiacombo")
            CassiopeiaConfig:addParam("scriptActive", "Active", SCRIPT_PARAM_ONKEYDOWN, false, 32)
            CassiopeiaConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
            CassiopeiaConfig:addParam("useW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
            CassiopeiaConfig:addParam("useUlticombo", "Use Ultimate only when killable", SCRIPT_PARAM_ONOFF, true)
            CassiopeiaConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, false)
            CassiopeiaConfig:permaShow("scriptActive")
            ts = TargetSelector(TARGET_LOW_HP,range,DAMAGE_MAGIC,false)
            ts.name = "Cassiopeia"
            CassiopeiaConfig:addTS(ts)
            if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
            elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
            for i=1, heroManager.iCount do poisonedtime[i] = 0 waittxt[i] = i*3 end
    end
     
    function OnTick()
            ts:update()
            DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
            local tq = TargetPrediction(850, 99, 500, 0, 99)
            QREADY = (myHero:CanUseSpell(_Q) == READY)
            WREADY = (myHero:CanUseSpell(_W) == READY)
            EREADY = (myHero:CanUseSpell(_E) == READY)
            RREADY = (myHero:CanUseSpell(_R) == READY)
            DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
            HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
            BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
            IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
            if tick == nil or GetTickCount()-tick>=100 then
                    tick = GetTickCount()
                    SCDmgCalculation()
            end
            if CassiopeiaConfig.autoignite then    
                    if IREADY then
                            local ignitedmg = 0    
                            for j = 1, heroManager.iCount, 1 do
                                    local enemyhero = heroManager:getHero(j)
                                    if ValidTarget(enemyhero,600) then
                                            ignitedmg = 50 + 20 * myHero.level
                                            if enemyhero.health < ignitedmg then
                                                    CastSpell(ignite, enemyhero)
                                            end
                                    end
                            end
                    end
            end
            if ts.index ~= nil then poisonedtimets = poisonedtime[ts.index] end
            if CassiopeiaConfig.scriptActive and ts.target ~= nil then
                    if DFGREADY then CastSpell(DFGSlot, ts.target) end
                    if HXGREADY then CastSpell(HXGSlot, ts.target) end
                    if BWCREADY then CastSpell(BWCSlot, ts.target) end
                    qq = tq:GetPrediction(ts.target)
                    if qq ~= nil and QREADY and GetDistance(ts.target) <= range then
                            CastSpell(_Q, qq.x, qq.z)
                    end
                    if WREADY and CassiopeiaConfig.useW and GetDistance(ts.target) <= range then CastSpell(_W, ts.target) end
                    if EREADY and GetDistance(ts.target) <= erange and (GetTickCount()-poisonedtimets < 2600) then CastSpell(_E, ts.target) end
                    local rdmg = getDmg("R",ts.target,myHero)
                    if RREADY and CassiopeiaConfig.useUlticombo and ts.target.health < rdmg and GetDistance(ts.target) < range then
                            CastSpell(_R, ts.target)
                    end
                    --if RREADY and not CassiopeiaConfig.useUlticombo and GetDistance(ts.target) < range then
                            --CastSpell(_R, ts.target)
                    --end  
            end
    end
    function OnCreateObj(obj)
            if obj.name:find("Global_Poison") then
                    for i=1, heroManager.iCount do
                            local enemy = heroManager:GetHero(i)
                            if enemy.team ~= myHero.team and GetDistance(obj, enemy) < 80 then poisonedtime[i] = GetTickCount() end
                    end
            end
    end
    function SCDmgCalculation()
            local enemy = heroManager:GetHero(calculationenemy)
            if ValidTarget(enemy) then
                    local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
                    local qdamage = getDmg("Q",enemy,myHero)
                    local wdamage = getDmg("W",enemy,myHero)
                    local edamage = getDmg("E",enemy,myHero) --xHit
                    local rdamage = getDmg("R",enemy,myHero)
                    local hitdamage = getDmg("AD",enemy,myHero)
            local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
            local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
            local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)        
                    local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
                    local Sheendamage = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)
                    local Trinitydamage = (TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)
                    local LichBanedamage = (LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)
                    local combo1 = qdamage + wdamage + edamage*5 + rdamage + Sheendamage + Trinitydamage + LichBanedamage
                    local combo2 = Sheendamage + Trinitydamage + LichBanedamage
                    local combo3 = Sheendamage + Trinitydamage + LichBanedamage
                    local combo4 = 0
                    if QREADY then
                            combo2 = combo2 + qdamage
                            combo3 = combo3 + qdamage
                    end
                    if WREADY then
                            combo2 = combo2 + wdamage
                            combo3 = combo3 + wdamage
                    end
                    if EREADY then
                            combo2 = combo2 + edamage*5
                            combo3 = combo3 + edamage*3
                            combo4 = combo4 + edamage
                    end
            if DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY then        
                combo1 = combo1 + dfgdamage            
                combo2 = combo2 + dfgdamage
                combo3 = combo3 + dfgdamage
            end
            if HXGSlot ~= nil and  myHero:CanUseSpell(HXGSlot) == READY then              
                combo1 = combo1 + hxgdamage    
                combo2 = combo2 + hxgdamage
                combo3 = combo3 + hxgdamage
             end
            if BWCSlot ~= nil and  myHero:CanUseSpell(BWCSlot) == READY then
                combo1 = combo1 + bwcdamage
                combo2 = combo2 + bwcdamage
                combo3 = combo3 + bwcdamage
            end            
                    if RREADY then
                            combo2 = combo2 + rdamage
                            combo3 = combo3 + rdamage
                            combo4 = combo4 + rdamage
                    end
                    if IREADY then
                            combo1 = combo1 + ignitedamage
                            combo2 = combo2 + ignitedamage
                            combo3 = combo3 + ignitedamage
                    end
                    if combo4 >= enemy.health then killable[calculationenemy] = 4
                    elseif combo3 >= enemy.health then killable[calculationenemy] = 3
                    elseif combo2 >= enemy.health then killable[calculationenemy] = 2
                    elseif combo1 >= enemy.health then killable[calculationenemy] = 1
                    else killable[calculationenemy] = 0 end
            end
            if calculationenemy == 1 then calculationenemy = heroManager.iCount
            else calculationenemy = calculationenemy-1 end
    end
    function OnDraw()
            if CassiopeiaConfig.drawcircles and not myHero.dead then
                    DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x9999FF)
                    DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0xFF6600)
                    if ts.target ~= nil then
                            for j=0, 15 do
                                    DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
                            end
                    end
            end
            for i=1, heroManager.iCount do
                    local enemydraw = heroManager:GetHero(i)
                    if ValidTarget(enemydraw) then
                            if CassiopeiaConfig.drawcircles then
                                    if killable[i] == 1 then
                                            for j=0, 20 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
                                            end
                                    elseif killable[i] == 2 then
                                            for j=0, 10 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
                                            end
                                    elseif killable[i] == 3 then
                                            for j=0, 10 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
                                            end
                                    elseif killable[i] == 4 then
                                            for j=0, 10 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
                                            end
                                    end
                            end
                            if CassiopeiaConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
                                    PrintFloatText(enemydraw,0,floattext[killable[i]])
                            end
                    end
                    if waittxt[i] == 1 then waittxt[i] = 30
                    else waittxt[i] = waittxt[i]-1 end
            end
    end

