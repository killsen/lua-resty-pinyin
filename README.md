# 中文转拼音库

forked from [MissinA/pinyin](https://github.com/MissinA/pinyin)

## 代码示例
```lua

local pinyin = require "resty.pinyin"

local str = [[中文拼音]]

local fp, sp = pinyin.convert(str)
ngx.say("全拼: ", table.concat(fp, ", "))
ngx.say("简拼: ", table.concat(sp, ", "))

ngx.update_time()
local t1 = ngx.now() * 1000

for _ = 1, 100000 do
    pinyin.convert(str)
end

ngx.update_time()
local t2 = ngx.now() * 1000

ngx.say("耗时: ", t2 - t1, " ms")

```
