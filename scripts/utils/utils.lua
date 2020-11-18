require 'json'

local BASE_URL = "http://api.tumbleweedofall.xyz:8888"
local TOKEN = "0874689771c44c1e1828df13716801f5"

function ExistInTable(tab, val)
	for k, v in pairs(tab) do
		if v == val then
			return true
		end
	end
	return false
end

function HttpPost(url, cb, params)
	if params == nil then
		params = {}
	end
	params['token'] = TOKEN
	TheSim:QueryServer(
		BASE_URL..url,
		function(...) 
			if type(cb) == "function" then 
				cb(...) 
			end 
		end,
		"POST",
		json.encode(params) 
	)
end

function HttpGet(url, cb)
	TheSim:QueryServer( 
		BASE_URL..url, 
		function(result, isSuccessful, resultCode) 
			if type(cb) == "function" then 
				cb(result, isSuccessful, resultCode) 
			end 
		end, 
		"GET")
end

function ValueToString(value)
    if type(value)=='table' then
       return Table2String(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end

function Table2String(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ValueToString(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..ValueToString(key).."]="..ValueToString(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..Table2String(getmetatable(key)).."*e".."="..ValueToString(value)
                else
                    retstr = retstr..signal..key.."="..ValueToString(value)
                end
            end
        end

        i = i+1
    end

     retstr = retstr.."}"
     return retstr
end

function String2Table(str)
    if str == nil or type(str) ~= "string" then
        return
    end
    
    return loadstring("return " .. str)()
end