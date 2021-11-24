-- upload.lua
--==========================================
-- 文件上传
--==========================================
local upload = require "resty.upload"
local chunk_size = 4096

local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
form:set_timeout(1000)

-- 字符串 split 分割
string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
-- 支持字符串前后 trim
string.trim = function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- 文件保存的根路径
local request_uri = ngx.var.request_uri
local uriStr = string.split(request_uri, "/")
local date = uriStr[2]
local saveRootPath = ngx.var.store_dir .. "/" .. date .."/"
-- 保存的文件对象
local fileToSave
--文件是否成功保存
local ret_save = false
local filename = ""

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end
    if typ == "header" then
        -- 开始读取 http header
        -- 解析出本次上传的文件名
        local key = res[1]
        local value = res[2]
        if key == "Content-Disposition" then
            -- 解析出本次上传的文件名
            -- form-data; name="testFileName"; filename="testfile.txt"
            local kvlist = string.split(value, ';')
            for _, kv in ipairs(kvlist) do
                local seg = string.trim(kv)
                if seg:find("filename") then
                    local kvfile = string.split(seg, "=")
                    filename = string.sub(kvfile[2], 2, -2)
                    str = string.split(filename,".")
                    if filename then
                        fileToSave = io.open(saveRootPath .. filename, "w+")
                        if not fileToSave then
                            os.execute("mkdir -p " .. saveRootPath)
			                fileToSave = io.open(saveRootPath .. filename, "w+")
                        end
                        break
                    end
                end
            end
        end
    elseif typ == "body" then
        -- 开始读取 http body
        if fileToSave then
            fileToSave:write(res)
        end
    elseif typ == "part_end" then
        -- 文件写结束，关闭文件
        if fileToSave then
            fileToSave:close()
            fileToSave = nil
        end
         
        ret_save = true
    elseif typ == "eof" then
        -- 文件读取结束
        break
    else
        ngx.log(ngx.INFO, "do other things")
    end
end

if ret_save then
    local file = io.open(saveRootPath .. filename, "rb")
    if file == nil then
	ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
	ngx.say("file upload error")
	ngx.log(ngx.ERR,"file为空，filename=" .. filename)
	return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    ngx.print(filename)
end