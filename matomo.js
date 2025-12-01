var _paq = window._paq = window._paq || [];
/* tracker methods like "setCustomDimension" should be called before "trackPageView" */
// Call disableCookies before calling trackPageView 
_paq.push(['disableCookies']);
// accurately measure the time spent in the visit
_paq.push(['enableHeartBeatTimer']);
_paq.push(['trackPageView']);
_paq.push(['enableLinkTracking']);

(function() {
  var u="//matomo.sites.er.kcl.ac.uk/";
  _paq.push(['setTrackerUrl', u+'matomo.php']);
  _paq.push(['setSiteId', '1']);
  var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
  g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
})();

// Event Tracking Code
$(document).on('shiny:inputchanged', function(event) {
  _paq.push(['trackEvent', 'input',
    'updates', event.name, event.value]);
});
