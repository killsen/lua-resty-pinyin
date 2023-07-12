
-- 为lua创造的快速中文转拼音库
-- https://github.com/MissinA/pinyin

local _sub      = string.sub
local _byte     = string.byte
local _newt     = table.new
local _concat   = table.concat

local __ = { _VERSION = "1.0.1" }

-- utf8字符串迭代器
local function ichars(str)
-- @str : string

    local pos, index = 1, 0

    -- utf8字符串迭代函数
    return function()
    -- @return : index?: number, char?: string

        if pos > #str then return nil, nil end

        local byte = _byte(str, pos)
        if not byte then return nil, nil end

        -- 字符长度
        local size = byte < 192 and 1
                  or byte < 224 and 2
                  or byte < 240 and 3
                  or byte < 248 and 4
                  or byte < 252 and 5
                  or 6

        local char = _sub(str, pos, pos + size - 1)

        pos = pos + size
        index = index + 1

        return index, char
    end
end

local PINYIN_MAP

-- 加载拼音表
local function load_pinyin_map()
-- @return  : map<string>

    if PINYIN_MAP then return PINYIN_MAP end
    PINYIN_MAP = _newt(0, 26800)  --> map<string>

    local data = require "resty.pinyin.data"

    for k, v in pairs(data) do
        for _, char in ichars(v) do
            PINYIN_MAP[char] = k
        end
    end

    package.loaded["resty.pinyin.data"] = nil
    return PINYIN_MAP

end

-- 按拼音比较字符串大小
__.compare = function(str1, str2)
-- @str1    : string
-- @str2    : string
-- @return  : boolean

    if str1 == str2 then return nil end

    if type(str1) ~= "string" or type(str2) ~= "string" then
        return nil
    end

    local map = load_pinyin_map()

    local iter1 = ichars(str1)
    local iter2 = ichars(str2)

    while true do
        local _, c1 = iter1()
        local _, c2 = iter2()

        if not c1 and c2 then
            return true
        elseif c1 and not c2 then
            return false
        elseif not c1 and not c2 then
            return nil
        end

        if #c1 ~= #c2 then
            return #c1 < #c2
        end

        if c1 ~= c2 then
            local py1 = map[c1] or c1
            local py2 = map[c2] or c2
            if py1 ~= py2 then
                return py1 < py2
            else
                return c1 < c2
            end
        end
    end

end

-- 返回全拼及简拼
__.convert = function(str)
-- @str     : string
-- @return  : fp: string[], sp: string[]

    local fp = {}  --> string[]  // 全拼
    local sp = {}  --> string[]  // 简拼

    if type(str) ~= "string" then
        return fp, sp
    end

    local map = load_pinyin_map()

    for i, char in ichars(str) do
        local py = map[char]
        if py then
            fp[i] = py
            sp[i] = _sub(py, 1, 1)
        else
            fp[i] = char
            sp[i] = char
        end
    end

    return fp, sp

end

-- 测试
__._TESTING = function()

    local str = [[汉字拼音]]

    local fp, sp = __.convert(str)
    ngx.say("全拼: ", _concat(fp, ", "))
    ngx.say("简拼: ", _concat(sp, ", "))

    ngx.update_time()
    local t1 = ngx.now() * 1000

    for _ = 1, 100000 do
        __.convert(str)
    end

    ngx.update_time()
    local t2 = ngx.now() * 1000

    ngx.say("转换十万次耗时: ", t2 - t1, " ms")

    local names = {
        "武三", "吴三", "吴四", "武四"
    }

    table.sort(names, __.compare)

    for i, name in ipairs(names) do
        local py = _concat(__.convert(name), ", ")
        ngx.say(i, ") ", name, " : ", py)
    end

    -- 1) 吴三 : wu, san
    -- 2) 吴四 : wu, si
    -- 3) 武三 : wu, san
    -- 4) 武四 : wu, si

end

return __
