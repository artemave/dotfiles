function map(tbl, f)
  local t = {}
  for k,v in pairs(tbl) do
    table.insert(t, f(k, v))
  end
  return t
end

function join(tbl, sep)
  local ret = ''
  for i, v in pairs(tbl) do
    ret = ret .. v .. sep
  end
  return ret:sub(1, -#sep - 1)
end
