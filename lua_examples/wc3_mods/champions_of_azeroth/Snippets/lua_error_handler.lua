function RunMyErrorMaker()

	local function MakeAnError()
	   local n = n/nil
	end

	local function PrintTheError( err )
	   print( "ERROR:", err )
	end

	local status = xpcall( MakeAnError, PrintTheError )
	print( status)

	print('initialized success')

end
