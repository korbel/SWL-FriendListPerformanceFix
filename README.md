# FriendListPerformanceFix SWL mod

This mod disables the automatic refresh of the Friends List and Cabal Management windows.

Additional features:
- Adds a refresh button to the Friends List window
- Fixes the depth layers of the buttons on the Friends List window so the buttons don't hide the right-click menu anymore
- Adds an "Invite to Raid" menu entry to the right-click menu of the Friends List window when you are the leader of a raid
- Changes the date format on the member list of the Cabal Management window
- Automatically refreshes the contents of the above mentioned windows with a 500ms of delay in the following cases:
  - Adding/Removing a friend
  - Promote/Demote/Remove a guild member
  - Ignore/Unignore a player

IMPORTANT NOTE: In case of heavy lags or high ping the 500ms of delay may not be enough for the server to update your friend lists. If you don't see the expected changes in the list, click the refresh button.


## Installation instructions

Extract the zip file into `<SWL directory>\Data\Gui\Custom\Flash\` and restart the game.
To check if the mod was installed properly, open you Friends window and check if you have a REFRESH button at the bottom left corner.
