# MusicRadio



This is yet another radio stations player based on the [RadioBrowser](https://www.radio-browser.info/) and its server at [Community Radio Station Index](https://de1.api.radio-browser.info/#General).

This project uses SwiftUI and SwiftData to store the list of countries and the “Favourite” stations, but not all of the stations. 

Was meant to be a weekend project but ended up taking a week to polish.


<p float="left">
  <img src="ScreenShots/picture1.png"  width="200"  height="400" />
  <img src="ScreenShots/picture2.png"  width="200"  height="400" /> 
  <img src="ScreenShots/picture3.png"  width="200"  height="400" /> 
</p>


## Usage

Tap/click on the station you want to listen to, and it will appear 
in the **Play** bar at the bottom of the screen.

Search for the country you desire, then tap/click on the **heart** icon to 
make the station **Favourite**. That radio station will appear in the **Favourites** list.

Similarly, when you search for particular **Stations**.

Tap/click on the **globe** icon of a radio station to bring its internet home page, if it has one.

## Note

Some radio stations url are **http** not **https** as required my Apple.
So currently the NSAppTransportSecurity permissions in Info.plist is set to 
NSAllowsArbitraryLoads.
        
Note also, the type of station displayed between the **heart** and the **globe** icons, 
is inferred based on the various tags the station wants to be known for.    
        
