using Toybox.Application as App;

class SimplySunTimesWidgetApp extends App.AppBase {
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
        SunTimesView = new SimplySunTimesWidgetView();
        return [ SunTimesView, new SimplySunTimesWidgetDelegate(SunTimesView) ];
    }

}