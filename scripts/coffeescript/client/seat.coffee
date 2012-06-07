root = exports ? this

root.Seat =
	Self: 0
	Left: 1
	Across: 2
	Right: 3

	toString: (seat) ->
		switch seat
			when Seat.Self then 'self'
			when Seat.Left then 'left'
			when Seat.Across then 'across'
			when Seat.Right then 'right'

	nextSeat: (seat) ->
		switch seat
			when Seat.Self then Seat.Left
			when Seat.Left then Seat.Across
			when Seat.Across then Seat.Right
			when Seat.Right then Seat.Self
