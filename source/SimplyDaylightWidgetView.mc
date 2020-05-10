using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time as Time;
using Toybox.Position as Position;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

class SimplyDaylightWidgetView extends Ui.View {
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
    function Draw(set, useGrey) {
	        View.findDrawableById("title").setText(title[set]);
			var val = View.findDrawableById("value");
			val.setText(suntimes[set][0]);
			val.setColor(useGrey ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_WHITE);
			View.findDrawableById("day").setText(suntimes[set][2] + " " + suntimes[set][1]);
	}
	
	(:twoLines)
    function Draw(set, useGrey) {
	        View.findDrawableById("title").setText(title[set]);
			View.findDrawableById("value").setText(suntimes[set][0]);
			var val = View.findDrawableById("value");
			val.setText(suntimes[set][0]);
			val.setColor(useGrey ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_WHITE);
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
				if (myInfo.accuracy >= Position.QUALITY_POOR) {
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
					needGPS = false;
	    		}
	    	}
		}
//	    	    myInfo.position = Position.parse("53.825564, -2.421976", Position.GEO_DEG);
//	    	    myInfo.position = Position.parse("34.0522, -118.2437", Position.GEO_DEG);
// Tokyo 35.6762, 139.6503
		if (myInfo.accuracy > Position.QUALITY_NOT_AVAILABLE) {
    		var sc = new SunCalc();
    		var loc = myInfo.position.toRadians();
	    	var time_now = Time.now();
	    	var time_tomorrow = time_now.add(new Time.Duration(Gregorian.SECONDS_PER_DAY));
	    	var sunrise_time = sc.calculate(time_now, loc[0], loc[1], SUNRISE);
	    	if (sunrise_time != null && sunrise_time.lessThan(time_now)) {
	    		sunrise_time = sc.calculate(time_tomorrow, loc[0], loc[1], SUNRISE);
	    	}
	    	var sunset_time = sc.calculate(time_now, loc[0], loc[1], SUNSET);
	    	if (sunset_time != null && sunset_time.lessThan(time_now)) {
	    		sunset_time = sc.calculate(time_tomorrow, loc[0], loc[1], SUNSET);
	    	}
	    	if (sunrise_time == null || sunset_time == null) {
				title[set] = "No time";
				suntimes[set] = ["00:00", "", ""];
			} else {
		    	if (!selected && sunset_time.lessThan(sunrise_time)) {
		    		set = 1;
	    		}
	    		suntimes[0] = sc.momentToString(sunrise_time, Today, Tomorrow);
	    		suntimes[1] = sc.momentToString(sunset_time, Today, Tomorrow);
				title = titles;
			}
		} else {
			title[set] = "No GPS";
			suntimes[set] = ["00:00", "", ""];
		}
		if (suntimes[set][0] != null) {
		   	Draw(set, myInfo.accuracy == Position.QUALITY_LAST_KNOWN);
		}

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

(:glance)
class SimplyDaylightWidgetGlanceView extends Ui.GlanceView {
	var vcentre = 80;

	function initialize() {
		GlanceView.initialize();
	}

	function onLayout(dc) {
		vcentre = dc.getFontHeight(Gfx.FONT_SMALL) - 10;
	}

	function onUpdate(dc) {
		var suntime = ["", "", ""];
    	var sunevent = "";
	    var	myInfo = Position.getInfo();
//	    	    myInfo.position = Position.parse("53.825564, -2.421976", Position.GEO_DEG);
//	    	    myInfo.position = Position.parse("34.0522, -118.2437", Position.GEO_DEG);
// Tokyo 35.6762, 139.6503

		if (myInfo.accuracy > Position.QUALITY_NOT_AVAILABLE && myInfo.position != null) {
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
	    	var time;
	    	if (sunset_time.lessThan(sunrise_time)) {
		    	time = sunset_time;
		    	sunevent = "Sunset ";
		    } else {
		    	time = sunrise_time;
		    	sunevent = "Sunrise ";
		    }
	    	suntime = sc.momentToString(time, "", "");
		}
		dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
		dc.clear();
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
		dc.drawText(0, -7, Gfx.FONT_SMALL, "Simply Daylight", Gfx.TEXT_JUSTIFY_LEFT);
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(0, vcentre, Gfx.FONT_TINY, sunevent, Gfx.TEXT_JUSTIFY_LEFT);
		if (myInfo.accuracy == Position.QUALITY_LAST_KNOWN) {
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		}
		var x = dc.getTextDimensions("Simply ", Gfx.FONT_SMALL)[0];
		dc.drawText(x, vcentre, Gfx.FONT_TINY, suntime[0], Gfx.TEXT_JUSTIFY_LEFT);
	}

}
