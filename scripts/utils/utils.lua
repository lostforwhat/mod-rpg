function ExistInTable(tab, val)
	for k, v in pairs(tab) do
		if v == val then
			return true
		end
	end
	return false
end