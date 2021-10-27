using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class SimplyDaylightWidgetDelegate extends Ui.BehaviorDelegate {
    /* Initialize and get a reference to the view, so that
     * user iterations can call methods in the main view. */
     var SSTView;
     var lastSet;
     
    function initialize(view) {
        Ui.BehaviorDelegate.initialize();
        SSTView = view;
    }

    function onSelect() {
    	if (SSTView.set != 2) {
	        SSTView.set = (SSTView.set + 1) % 2;
        	SSTView.selected = true;
        }
        Ui.requestUpdate();
        return true;
    }

    function onMenu() {
    	if (SSTView.set != 2) {
	        lastSet = SSTView.set;
    	    SSTView.set = 2;
        } else {
        	SSTView.set = lastSet;
        }
       	SSTView.selected = true;
        Ui.requestUpdate();
        return true;
    }
}
