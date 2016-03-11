
local config = require "lua.comm.config"
local mysql = require "resty.mysql"

local _M = {}

function _M.conn_db(self)
    local db, err = mysql:new()
    if not db or err then
        ngx.log(ngx.ERR, "mysql:new failed: ", err)
        return db, err
    end
	
    db:set_timeout(1000) -- 1 sec
	
    local ok, err = db:connect{
        host = config.MYSQL_HOST,
        port = config.MYSQL_PORT,
        database = config.MYSQL_DB,
        user = config.MYSQL_USER,
        password = config.MYSQL_PASSWORD,
        max_packet_size = 1024 * 1024 }
    if not ok or err then
        ngx.log(ngx.ERR, "mysql:connect failed: ", err)
        return nil, err
    end
	
    ngx.log(ngx.INFO, "mysql:conn_db")
    return db, err
end

function _M.set_keepalive_mod(conn)
    ngx.log(ngx.INFO, "mysql:set_keepalive")	
    return conn:set_keepalive(60*1000, 50) -- put it into the connection pool of size 50, with 10 seconds max idle time
end

function _M.do_cmd(self, cmd)
    local db, err = self:conn_db()
    if not db or err then
        return nil, err
    end

    local res, err = db:query(cmd)
    if not res or err then
        ngx.log(ngx.ERR, "mysql:query failed, err: ", err, " cmd: ", cmd)
        --return nil, err
    end
    
    self.set_keepalive_mod(db)

    return res, err
end


return _M
