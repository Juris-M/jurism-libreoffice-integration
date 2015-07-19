/*
    ***** BEGIN LICENSE BLOCK *****
	
	Copyright (c) 2015  Juris-M
	                    Frank Bennett
						Nagoya, JAPAN
						https://juris-m.github.io
	
	Juris-M is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	Juris-M is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.
	
	You should have received a copy of the GNU Affero General Public License
	along with Zotero.  If not, see <http://www.gnu.org/licenses/>.
    
    ***** END LICENSE BLOCK *****
*/

var EXPORTED_SYMBOLS = ["Checker"];

const Cc = Components.classes;
const Ci = Components.interfaces;
const Cu = Components.utils;

var Checker = function(title, msg, thisID, thisDesc, parentID, parentDesc) {
    Cu.import("resource://gre/modules/AddonManager.jsm");  
    AddonManager.getAddonByID(parentID, function(parentAddon) {
        if (parentAddon && !parentAddon.userDisabled) {
            AddonManager.getAddonByID(thisID, function (thisAddon) {
                // Send the user a message
                var select = {};
		        Cc["@mozilla.org/embedcomp/prompt-service;1"]
			        .getService(Ci.nsIPromptService)
			        .select(null, title, msg, 2, [thisDesc, parentDesc], select);
                
                if (select.value == 0) {
                    parentAddon.userDisabled = true;
                } else {
                    thisAddon.userDisabled = true;
                }
                Cu.import("resource://gre/modules/Services.jsm");
                Services.prefs.setBoolPref("browser.sessionstore.resume_session_once", true);
                const nsIAppStartup = Components.interfaces.nsIAppStartup;
                Cc["@mozilla.org/toolkit/app-startup;1"]
                    .getService(nsIAppStartup)
                    .quit(nsIAppStartup.eRestart | nsIAppStartup.eAttemptQuit);
            });
        }
    });
}
