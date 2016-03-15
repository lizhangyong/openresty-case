
local db  = require "lua.db.db_mysql"

local _M = {}

function _M.conn_db(self)
    return db:conn_db()
end

function _M.do_cmd(self, cmd)
    if cmd then
        return db:do_cmd(cmd)
    end
end

return _M
