local default_count = 10000
local default_probability = 0.01
local default_ttl = 14400 -- 4 hours (0 for never)

local bloom_filter = require "bloom_filter"

function add(rec, bin, value, conf)
    local items = conf.items or default_count
    local probability = conf.probabilty or default_probability
    local ttl = conf.ttl or default_ttl

    local function storeBloom(bf, rec, bin)
        rec[bin] = bf.data
        rec[bin .. "_probability"] = bf.probability
        rec[bin .. "_items"] = bf.items
        return rec
    end

    local function createBloom(cnt, probability)
        local bf = bloom_filter.__new(cnt, probability)
        bf.data = bytes(bf.bytes)

        -- hack (bytes are initialized to nil)
        for i = 0, bf.bytes  do
            bf.data[i] = 0
        end
        return bf
    end

    if default_ttl > 0 then
        record.set_ttl(rec, default_ttl)
    end

    local found = false

    if aerospike:exists(rec) then
        if rec[bin] ~= nil then
            local bf = bloom_filter.load({
                data = rec[bin],
                items = rec[bin .. "_items"],
                probability = rec[bin .. "_probability"],
            })
            found = bf:query(value)
            if found == 0 then
                bf:add(value)
                rec[bin] = bf.data
                aerospike:update(rec)
            end
        else
            -- record exists, but bin does not
            local bf = createBloom(items, probability)
            bf:add(value)
            rec = storeBloom(bf:store(), rec, bin)
            aerospike:update(rec)
        end
    else
        local bf = createBloom(items, probability)
        bf:add(value)
        rec = storeBloom(bf:store(), rec, bin)
        aerospike:create(rec)
    end
    return found
end

function clear(rec, bin)
    local bf = bloom_filter.load({
        data = rec[bin],
        items = rec[bin .. "_items"],
        probability = rec[bin .. "_probability"],
    })
    bf:clear()
end

function query(rec, bin, val)
     local bf = bloom_filter.load({
        data = rec[bin],
        items = rec[bin .. "_items"],
        probability = rec[bin .. "_probability"],
    })
    return bf:query(value)
end
