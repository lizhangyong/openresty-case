
local db  = require "lua.db.db_mysql"


local _M = {}
local _M = { _VERSION = '1.0' }


function _M.conn_db(self)
    return db:conn_db()
end


function _M.do_cmd(self, cmd)
    if cmd then
        return db:do_cmd(cmd)
    end
end


return _M
