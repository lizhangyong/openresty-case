module(..., package.seeall)

local db  = require "lua.db.db_mysql"

function conn_db()
    return db:conn_db()
end

function do_cmd(cmd)
    if cmd then
        return db:do_cmd(cmd)
    end
end

--以下代码暂未测试， 先注释
--local db  = require "lua.db.db_mysql"

--local _M = {}

--function _M.conn_db(self)
--    return db:conn_db()
--end

--function _M.do_cmd(self, cmd)
--    if cmd then
--        return db:do_cmd(cmd)
--    end
--end

--return _M
