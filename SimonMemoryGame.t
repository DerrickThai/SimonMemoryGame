% Simon Memory Game
% Derrick Thai and Kenton Yeung
% June 7 2013

% Declare and Initialize Constants
const CENTREX : int := maxx div 2
const CENTREY : int := maxy div 2

% Declare all Variables
var lightY : int := CENTREY
var lightX, lightOnColour, lightOffColour : array 1 .. 4 of int
var level : int := 1
var pattern : flexible array 1 .. level of int
var input : string (1)
var original, current : int
original := 120

% Initialize Variables
% Light X variables
lightX (1) := CENTREX - 90
lightX (2) := CENTREX - 30
lightX (3) := CENTREX + 30
lightX (4) := CENTREX + 90

% Light on colours
lightOnColour (1) := 40
lightOnColour (2) := 48
lightOnColour (3) := 44
lightOnColour (4) := 40

% Light off coloues
lightOffColour (1) := 112
lightOffColour (2) := 119
lightOffColour (3) := 115
lightOffColour (4) := 112

% Procedures
proc DrawBox    % Draws the box that holds the lights
    drawfillbox (CENTREX - 130, CENTREY - 30, CENTREX + 130, CENTREY + 30, 28)
    drawbox (CENTREX - 130, CENTREY - 30, CENTREX + 130, CENTREY + 30, black)
end DrawBox

% Turns on all of the lights
proc OnLightAll
    for i : 1 .. 4
	drawfilloval (lightX (i), lightY, 20, 20, lightOnColour (i))
	drawoval (lightX (i), lightY, 20, 20, black)
    end for
end OnLightAll

% Turns off all of the lights
proc OffLightAll
    for i : 1 .. 4
	drawfilloval (lightX (i), lightY, 20, 20, lightOffColour (i))
	drawoval (lightX (i), lightY, 20, 20, black)
    end for
end OffLightAll

% Turns on the light that is in the parameter
proc OnLight (num : int)
    drawfilloval (lightX (num), lightY, 20, 20, lightOnColour (num))
    drawoval (lightX (num), lightY, 20, 20, black)
    % Turn on the light through parallelput
    parallelput (2 ** (num - 1))
end OnLight

% Turns off the light that is in the parameter
proc OffLight (num : int)
    drawfilloval (lightX (num), lightY, 20, 20, lightOffColour (num))
    drawoval (lightX (num), lightY, 20, 20, black)
    parallelput (0)
end OffLight

% MAIN
loop
    % Call Procedures
    DrawBox
    OffLightAll

    % Determine what text to display
    if level = 1 then
	put "Hit any key to begin"
	loop
	    % Wait for player to press any button
	    exit when parallelget not= 120
	end loop

	% Starting light sequence
	parallelput (1 + 2 + 4 + 8)
	delay (1000)
	parallelput (0)
	delay (1000)
    else
	% Run code once for each light in the pattern
	for i : 1 .. (level - 1)

	    loop
		% Get data from parallel port
		current := parallelget
		exit when current not= original
	    end loop

	    loop
		% Wait for user to release button
		exit when parallelget = 120
	    end loop

	    delay (100)

	    % Check the user input
	    if current = 56 then
		input := "1"
	    elsif current = 248 then
		input := "2"
	    elsif current = 88 then
		input := "3"
	    elsif current = 112 then
		input := "4"
	    end if

	    % Display what the user presses
	    OnLight (strint (input))
	    delay (100)
	    OffLight (strint (input))

	    % Check if user input is correct
	    if input not= intstr (pattern (i)) then
		% Show the losing game light sequence
		parallelput (1 + 2 + 4 + 8)
		delay (100)
		parallelput (0)
		delay (100)
		parallelput (1 + 2 + 4 + 8)
		delay (1000)
		OnLight (pattern (i))
		% Quit program if user does not get pattern correct
		quit
	    end if
	end for

	% Display Level
	locate (1, 1)
	put "Level ", level - 1, " complete"
	delay (1000)
    end if

    % Select a random light for the next element of the patter
    pattern (level) := Rand.Int (1, 4)

    % Display the new pattern
    for i : 1 .. level
	OnLight (pattern (i))
	delay (1000)
	OffLight (pattern (i))
	delay (250)
    end for

    % Increase level + the number of pattern elements
    level += 1
    new pattern, level
end loop
