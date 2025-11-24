local LINGSOIL = GameMain:GetMod("LINGSOIL");
local flag = 0;
local index = 0;
local count = 0;

function LINGSOIL:OnInit()
count = GridMgr.GridCount - 1;
end

function LINGSOIL:OnStep(dt)
    if flag == 0 then
        local batchSize = 10  -- 每批处理10个地格
        for i = 1, batchSize do
            if index <= count then
                Map.Terrain:FullTerrain(index, "LingSoil")
                index = index + 1
            else
                flag = 1
                index = 0
                break
            end
        end
    end
end


function LINGSOIL:OnSave()
    local tbSave = {index, flag};
    return tbSave;
end

function LINGSOIL:OnLoad(tbLoad)
    if tbLoad ~= nil then
        index = tbLoad[1] or 0  -- 使用数字索引访问
        flag = tbLoad[2] or 0
    end
end
