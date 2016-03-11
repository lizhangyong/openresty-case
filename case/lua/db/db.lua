module(..., package.seeall)

local db  = require "lua.db.db_mysql"

local _M = {}

function  _M.conn_db()
    return db.conn_db()
end

function  _M.do_cmd(cmd)
    return db.do_cmd(key)
end

return _M
