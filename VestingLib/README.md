VestingLib
=========================   


Allows the owner to set up a contract to have linear vesting of ETH or tokens over a specified period of time.

The owner initializes the contract with an indication of whether it is tokens or ETH, a start time, end time, and the number of times the balance vests.
It calculates the interval between vests and the percentage vested at each interval

Before the vesting starts, the owner has to initialize the balance of the contract.  If it is ETH, he will call the initializeETHBalance function with an accompanying payment
If if is tokens, the owner has to send tokens to the contract, then call the initializeTokenBalance function.

The owner is also able to register and unregister users before the sale starts.  Users are also able to swap their registration with another address if they choose whenever they want.

Users can call the withdraw function whenever they want and it calculates the amount they are allowed to withdraw at that point.  It then sends the ETH or tokens if there is any available.  