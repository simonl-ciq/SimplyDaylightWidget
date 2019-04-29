using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class SimplySunTimesWidgetDelegate extends Ui.BehaviorDelegate {
    /* Initialize and get a reference to the view, so that
     * user iterations can call methods in the main view. */
     var SSTView;
     
    function initialize(view) {
        Ui.BehaviorDelegate.initialize();
        SSTView = view;
    }

    function onSelect() {
        SSTView.set = (SSTView.set + 1) % 2;
        SSTView.selected = true;
        Ui.requestUpdate();
        return true;
    }

    /* Menu button press. */
/*
    function onMenu() {
        parentView.set = parentView.set ? false : true;
        Ui.requestUpdate();
        return true;
    }
*/
}
