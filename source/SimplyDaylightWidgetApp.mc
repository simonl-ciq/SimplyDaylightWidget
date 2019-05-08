using Toybox.Application as App;

class SimplyDaylightWidgetApp extends App.AppBase {
	hidden var SunTimesView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        SunTimesView = new SimplyDaylightWidgetView();
        return [ SunTimesView, new SimplyDaylightWidgetDelegate(SunTimesView) ];
    }

}