
mids_table = {}
mid = "273f6bbce467fbb20bd8a14343429000"

for i = 1, 999 do
    mids_table[i] = string.format("%s67fbb20bd8a14343429%03d", string.sub(os.time(), 0, 10), i)
end 

math.randomseed(tostring(os.time()):reverse():sub(1, 6))

request = function()
   wrk.host = "10.16.93.178"
   wrk.port = 8080
   path = "/openresty-case/api-test?mid=" .. mid 
   mid = mids_table[math.random(1,999)]
   return wrk.format(nil, path)
end

