local LINGSOIL = GameMain:GetMod("LINGSOIL");

-- 将变量定义为mod的成员变量，避免全局污染
LINGSOIL.flag = 0;
LINGSOIL.index = 0;
LINGSOIL.count = 0;
LINGSOIL.lastProgress = 0  -- 记录上次进度百分比，避免重复提示
LINGSOIL.lastNotifyTime = 0  -- 记录上次通知时间

function LINGSOIL:OnInit()
    if GridMgr and GridMgr.GridCount then
        self.count = math.max(0, GridMgr.GridCount - 1)  -- 确保不为负数
    else
        self.count = 0  -- 提供默认值
    end
    print("LINGSOIL: 初始化完成，总地格数: " .. tostring(self.count + 1))
end

function LINGSOIL:OnStep(dt)
    if self.flag == 0 then
        local batchSize = 10  -- 每批处理10个地格
        
        for i = 1, batchSize do
            if self.index <= self.count then
                -- 添加错误处理，防止地形操作失败
                local success, result = pcall(function()
                    Map.Terrain:FullTerrain(self.index, "LingSoil")
                end)
                
                if not success then
                    print("LINGSOIL: 处理地格时出错 - " .. tostring(result))
                    self.flag = 2  -- 错误状态
                    break
                end
                
                self.index = self.index + 1
                
                -- 显示进度提示（每完成10%或每100个地格提示一次）
                self:ShowProgress()
            else
                self.flag = 1  -- 完成状态
                CS.XiaWorld.TipManager:AddTip("灵土转化完成！所有地格已成功转化为灵土。")
                print("LINGSOIL: 所有地格处理完成")
                break
            end
        end
    end
end

-- 显示进度提示的函数
function LINGSOIL:ShowProgress()
    if self.count <= 0 then return end
    
    local currentProgress = math.floor((self.index / self.count) * 100)
    
    -- 每10%进度提示一次，或者每处理100个地格提示一次
    if currentProgress >= self.lastProgress + 10 or 
       (self.index % 100 == 0 and currentProgress > self.lastProgress) then
        
        -- 防止频繁提示（至少间隔5秒）
        local currentTime = CS.UnityEngine.Time.time
        if currentTime - self.lastNotifyTime > 5 then
            local message = string.format("灵土转化进度: %d/%d (%.1f%%)", 
                self.index, self.count, currentProgress)
            
            -- 在游戏界面显示提示
            CS.XiaWorld.TipManager:AddTip(message)
            print("LINGSOIL: " .. message)
            
            self.lastProgress = currentProgress
            self.lastNotifyTime = currentTime
        end
    end
    
    -- 开始处理时显示初始提示
    if self.index == 1 then
        CS.XiaWorld.TipManager:AddTip("开始灵土转化进程...")
        print("LINGSOIL: 开始处理地格")
    end
end

function LINGSOIL:OnSave()
    local tbSave = {
        index = self.index,
        flag = self.flag,
        count = self.count,
        lastProgress = self.lastProgress,
        lastNotifyTime = self.lastNotifyTime
    };
    return tbSave;
end

function LINGSOIL:OnLoad(tbLoad)
    if tbLoad ~= nil then
        -- 使用更安全的方式访问表数据
        self.index = tbLoad.index or 0
        self.flag = tbLoad.flag or 0
        self.count = tbLoad.count or 0
        self.lastProgress = tbLoad.lastProgress or 0
        self.lastNotifyTime = tbLoad.lastNotifyTime or 0
        
        -- 一致性检查
        if self.index > self.count then
            self.index = 0
            self.flag = 0
            self.lastProgress = 0
        end
        
        -- 加载后显示当前进度
        if self.index > 0 and self.flag == 0 then
            local progress = math.floor((self.index / self.count) * 100)
            local message = string.format("继续灵土转化: %d/%d (%.1f%%)", 
                self.index, self.count, progress)
            CS.XiaWorld.TipManager:AddTip(message)
        end
        
        print(string.format("LINGSOIL: 加载进度 - 索引:%d, 状态:%d, 总数:%d, 进度:%d%%", 
              self.index, self.flag, self.count, math.floor((self.index / math.max(1, self.count)) * 100)))
    end
end

-- 添加一个命令函数用于手动检查进度
function LINGSOIL:CheckProgress()
    if self.count > 0 then
        local progress = math.floor((self.index / self.count) * 100)
        local message = string.format("当前灵土转化进度: %d/%d (%.1f%%) - 状态: %s", 
            self.index, self.count, progress, 
            self.flag == 0 and "进行中" or (self.flag == 1 and "已完成" or "错误"))
        CS.XiaWorld.TipManager:AddTip(message)
        print("LINGSOIL: " .. message)
    else
        CS.XiaWorld.TipManager:AddTip("灵土转化: 未开始或初始化失败")
    end
end
