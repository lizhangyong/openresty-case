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

return _M
