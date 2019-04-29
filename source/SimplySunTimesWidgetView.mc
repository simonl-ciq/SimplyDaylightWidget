using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Time as Time;
using Toybox.Position as Position;
using Toybox.Time.Gregorian;

class SimplySunTimesWidgetView extends Ui.View {
	var Today;
	var Tomorrow;

	var selected = false;
	var set = 0;
	var titles = ["Sunrise", "Sunset"];
	var title = [titles[0], titles[1]];
	var suntimes = [[null, null, null], [null, null, null]];
	var myInfo = null;
	var needGPS = true;

    function initialize() {
        View.initialize();
    }

    
/*
	function getNow() {
	var options = {
    	:year   => 2019,
    	:month  => 04,
    	:day    => 29,
    	:hour   => 00,
    	:minute => 0
		};
		return Gregorian.moment(options);
//		return Time.now();
	}    
*/

function momentToString(moment) {
	//https://github.com/haraldh/SunCalc/blob/master/source/SunCalcView.mc
		if (moment == null) {
			return "--:--";
		}

   		var tinfo = Time.Gregorian.info(new Time.Moment(moment.value() + 30), Time.FORMAT_SHORT);
		var XM="";
		var text="";
		var time;
		if (Sys.getDeviceSettings().is24Hour) {
			time = tinfo.hour.format("%02d") + ":" + tinfo.min.format("%02d");
		} else {
			var hour = tinfo.hour % 12;
			if (hour == 0) {
				hour = 12;
			}
			time = hour.format("%02d") + ":" + tinfo.min.format("%02d");
			if (tinfo.hour < 12 || tinfo.hour == 24) {
				XM = "AM";
			} else {
				XM = "PM";
			}
		}
		var now = Time.now();
		var days = (moment.value() / Time.Gregorian.SECONDS_PER_DAY).toNumber()
			- (now.value() / Time.Gregorian.SECONDS_PER_DAY).toNumber();

		if (days == 0) {
//			text = text + "today ";
			text = text + Today + " ";
		}
		
		if (days > 0) {
			if (days == 1) {
				//text = text + "tomorrow ";
				text = text + Tomorrow + " ";
			} else {
				text = text + "in " + days + " days ";
			}
		}
		if (days < 0) {
			if (days == -1) {
				text = text + "yesterday ";
			} else {
				text = text + "" + days + " days ";
			}
		}
		return [time, XM, text];
	}


	(:xtinyRound)
    function LayItOut() {
	    return [Gfx.getFontAscent(Gfx.FONT_XTINY), 8];
    }

	(:tinyRound)
    function LayItOut() {
	    return [Gfx.getFontAscent(Gfx.FONT_TINY), 10];
    }

	(:smallRound)
    function LayItOut() {
	    return [Gfx.getFontAscent(Gfx.FONT_SMALL), 8];
    }

	(:mediumRound)
    function LayItOut() {
	    return [Gfx.getFontAscent(Gfx.FONT_MEDIUM), 10];
    }

	(:smallRectangle)
    function LayItOut() {
	    return [Gfx.getFontAscent(Gfx.FONT_SMALL), 0];
    }

	(:mediumRectangle)
    function LayItOut() {
	    return [Gfx.getFontAscent(Gfx.FONT_MEDIUM), 0];
    }

	(:oneLine)
    function Draw(set) {
	        View.findDrawableById("title").setText(title[set]);
			View.findDrawableById("value").setText(suntimes[set][0]);
			View.findDrawableById("day").setText(suntimes[set][2] + " " + suntimes[set][1]);
	}
	
	(:twoLines)
    function Draw(set) {
	        View.findDrawableById("title").setText(title[set]);
			View.findDrawableById("value").setText(suntimes[set][0]);
			View.findDrawableById("hour").setText(suntimes[set][1]);
			View.findDrawableById("day").setText(suntimes[set][2]);
	}

    /* ======================== Position handling ========================== */

    function onPosition(info) {
    	myInfo = info;
        Ui.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
        Today = Ui.loadResource( Rez.Strings.Today );
        Tomorrow = Ui.loadResource( Rez.Strings.Tomorrow );
	    var params = LayItOut();
		View.setLayout(Rez.Layouts.MainLayout(dc));
		var value = View.findDrawableById("value");
		var hour = View.findDrawableById("hour");
		var day = View.findDrawableById("day");
		hour.locY = value.locY;
		hour.locY = hour.locY + Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT) - params[0];
		hour.locX = dc.getWidth() - 10;
		day.locY = value.locY + Gfx.getFontAscent(Gfx.FONT_NUMBER_THAI_HOT)+1;
		day.locX = hour.locX - params[1];
		myInfo = Position.getInfo();
        if (myInfo == null || myInfo.accuracy < Position.QUALITY_POOR) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
		}
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
//        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // Update the view
    function onUpdate(dc) {
		if (needGPS) {
	    	if (myInfo == null || myInfo.accuracy < Position.QUALITY_POOR) {
		    	myInfo = Position.getInfo();
		    }
			if (myInfo.accuracy != Position.QUALITY_NOT_AVAILABLE && myInfo.position != null) {
//	    	    myInfo.position = Position.parse("53.825564, -2.421976", Position.GEO_DEG);
//	    	    myInfo.position = Position.parse("53.322446, -2.645501", Position.GEO_DEG);

	    		var sc = new SunCalc();
	    		var loc = myInfo.position.toRadians();
		    	var time_now = Time.now();
		    	var time_tomorrow = time_now.add(new Time.Duration(Gregorian.SECONDS_PER_DAY));
		    	var sunrise_time = sc.calculate(time_now, loc[0], loc[1], SUNRISE);
		    	if (sunrise_time.lessThan(time_now)) {
		    		sunrise_time = sc.calculate(time_tomorrow, loc[0], loc[1], SUNRISE);
		    	}
		    	var sunset_time = sc.calculate(time_now, loc[0], loc[1], SUNSET);
		    	if (sunset_time.lessThan(time_now)) {
		    		sunset_time = sc.calculate(time_tomorrow, loc[0], loc[1], SUNSET);
		    	}
		    	if (!selected && sunset_time.lessThan(sunrise_time)) {
		    		set = 1;
		    	}
		    	suntimes[0] = momentToString(sunrise_time);
		    	suntimes[1] = momentToString(sunset_time);
				if (myInfo.accuracy >= Position.QUALITY_POOR) {
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
					needGPS = false;
				}
				title = titles;
	    	} else {
				title[set] = "No GPS";
				suntimes[set] = ["00:00", "", ""];
	    	}
	    }
	    if (suntimes[set][0] != null) {
	    	Draw(set);
		}
        myInfo = null;

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

}

