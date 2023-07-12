# 中文转拼音库

forked from [MissinA/pinyin](https://github.com/MissinA/pinyin)

## 代码示例
```lua

local pinyin = require "resty.pinyin"

local str = [[汉字拼音]]

local fp, sp = pinyin.convert(str)
ngx.say("全拼: ", _concat(fp, ", "))
ngx.say("简拼: ", _concat(sp, ", "))

ngx.update_time()
local t1 = ngx.now() * 1000

for _ = 1, 100000 do
    pinyin.convert(str)
end

ngx.update_time()
local t2 = ngx.now() * 1000

ngx.say("转换十万次耗时: ", t2 - t1, " ms")

local names = {
    "武三", "吴三", "吴四", "武四"
}

ngx.say("按拼音排序")
table.sort(names, pinyin.compare)

for i, name in ipairs(names) do
    local py = _concat(pinyin.convert(name), ", ")
    ngx.say(i, ") ", name, " : ", py)
end

-- 1) 吴三 : wu, san
-- 2) 吴四 : wu, si
-- 3) 武三 : wu, san
-- 4) 武四 : wu, si

```
