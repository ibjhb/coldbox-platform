<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	The main ColdBox utility library.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The main ColdBox utility library.">
	
	<!--- fileLastModified --->
	<cffunction name="fileLastModified" access="public" returntype="string" output="false" hint="Get the last modified date of a file">
		<cfargument name="filename" type="string" required="yes">
		<cfscript>
		var objFile =  createObject("java","java.io.File").init(javaCast("string",arguments.filename));
		// Calculate adjustments fot timezone and daylightsavindtime
		var offset = ((getTimeZoneInfo().utcHourOffset)+1)*-3600;
		// Date is returned as number of seconds since 1-1-1970
		return dateAdd('s', (round(objFile.lastModified()/1000))+offset, CreateDateTime(1970, 1, 1, 0, 0, 0));
		</cfscript>
	</cffunction>
	
	<!--- getAbsolutePath --->
	<cffunction name="getAbsolutePath" access="public" output="false" returntype="string" hint="Turn any system path, either relative or absolute, into a fully qualified one">
		<!--- ************************************************************* --->
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<!--- ************************************************************* --->
		<cfscript>
			var fileObj = createObject("java","java.io.File").init(javaCast("String",arguments.path));
			if(fileObj.isAbsolute()){
				return arguments.path;
			}
			return expandPath(arguments.path);
		</cfscript>
	</cffunction>
	
	<!--- inThread --->
	<cffunction name="inThread" output="false" access="public" returntype="boolean" hint="Check if you are in cfthread or not for any CFML Engine">
		<cfscript>
			var engine = "ADOBE";
			
			if ( server.coldfusion.productname eq "Railo" ){ engine = "RAILO"; }
			if ( server.coldfusion.productname eq "BlueDragon" ){ engine = "BD"; }
			
			switch(engine){
				case "ADOBE"	: { 
					if( findNoCase("cfthread",createObject("java","java.lang.Thread").currentThread().getThreadGroup().getName()) ){
						return true;
					}
					break;
				}
				
				case "RAILO"	: { 
					return getPageContext().hasFamily(); 
				}
				
				case "BD"		: { 
					if( findNoCase("cfthread",createObject("java","java.lang.Thread").currentThread().getThreadGroup().getName()) ){
						return true;
					}
					break;
				}
			} //end switch statement.
			
			return false;
		</cfscript>
	</cffunction>

	<!--- placeHolderReplacer --->
	<cffunction name="placeHolderReplacer" access="public" returntype="any" hint="PlaceHolder Replacer for strings containing ${} patterns" output="false" >
		<cfargument name="str" 		required="true" type="any" hint="The string variable to look for replacements">
		<cfargument name="settings" required="true" type="any" hint="The structure of settings to use in replacing">
		<cfscript>
			var returnString = arguments.str;
			var regex = "\$\{([0-9a-z\-\.\_]+)\}";
			var lookup = 0;
			var varName = 0;
			var varValue = 0;
			// Loop and Replace 
			while(true){
				// Search For Pattern
				lookup = reFindNocase(regex,returnString,1,true);	
				// Found?
				if( lookup.pos[1] ){
					//Get Variable Name From Pattern
					varName = mid(returnString,lookup.pos[2],lookup.len[2]);
					varValue = "VAR_NOT_FOUND";
					
					// Lookup Value
					if( structKeyExists(arguments.settings,varname) ){
						varValue = arguments.settings[varname];
					}
					// Lookup Nested Value
					else if( isDefined("arguments.settings.#varName#") ){
						varValue = Evaluate("arguments.settings.#varName#");
					}
					// Remove PlaceHolder Entirely
					returnString = removeChars(returnString, lookup.pos[1], lookup.len[1]);
					// Insert Var Value
					returnString = insert(varValue, returnString, lookup.pos[1]-1);
				}
				else{
					break;
				}	
			}
			
			return returnString;
		</cfscript>
	</cffunction>
	
	<!--- ripExtension --->
	<cffunction name="ripExtension" access="public" returntype="string" output="false" hint="Rip the extension of a filename.">
		<cfargument name="filename" type="string" required="true">
		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
	</cffunction>

	<!--- throw it --->
	<cffunction name="throwit" access="public" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- rethrowit --->
	<cffunction name="rethrowit" access="public" returntype="void" hint="Rethrow an exception" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The exception object">
		
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
	<!--- relocate --->
	<cffunction name="relocate" access="public" hint="Facade for cflocation" returntype="void" output="false">
		<cfargument name="url" 		required="true" 	type="string">
		<cfargument name="addtoken" required="false" 	type="boolean" default="false">
		
		<cflocation url="#arguments.url#" addtoken="#addtoken#">
	</cffunction>
	
	<!--- dump it --->
	<cffunction name="dumpit" access="public" hint="Facade for cfmx dump" returntype="void" output="true">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<!--- abort it --->
	<cffunction name="abortit" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<!--- include it --->
	<cffunction name="includeit" access="public" hint="Facade for cfinclude" returntype="void" output="false">
		<cfargument name="template" type="string" required="yes">
		
		<cfinclude template="#template#">
	</cffunction>

<!------------------------------------------- mixin methods ------------------------------------------>
	
	<!--- injectPropertyMixin --->
	<cffunction name="injectPropertyMixin" hint="Injects a property into the passed scope" access="public" returntype="void" output="false">
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	type="any" 		required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<cfscript>
			"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
		</cfscript>
	</cffunction>

	<!--- getPropertyMixin --->
	<cffunction name="getPropertyMixin" hint="Retrives a property from a mixed in container" access="public" returntype="any" output="false">
		<cfargument name="name" 	type="string" 	required="true" hint="The name of the property to retrieve"/>
		<cfargument name="scope" 	type="string" 	required="false" default="variables" hint="The scope to which to retrieve the property from"/>
		<cfargument name="default"  type="any"      required="false" hint="Default value to return, if property not found"/>
		<cfscript>
			var thisScope = variables;
			if( arguments.scope eq "this"){ thisScope = this; }
			
			if( NOT structKeyExists(thisScope,arguments.name) AND structKeyExists(arguments,"default")){
				return arguments.default;
			}
			
			return thisScope[arguments.name];
		</cfscript>
	</cffunction>
	
	<!--- injectUDFMixin --->
	<cffunction name="injectUDFMixin" hint="Injects a UDF into both public/private scopes in a CFC" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" hint="The name of the method to be injected">
		<cfargument name="UDF" type="any" hint="The UDF to inject">
		<cfscript>
			variables[arguments.name] = arguments.UDF;
			this[arguments.name] 	  = arguments.UDF;
		</cfscript>
	</cffunction>
	
	<!--- isInstanceCheck --->
    <cffunction name="isInstanceCheck" output="false" access="public" returntype="boolean" hint="Checks if an object is of a certain type of family via inheritance">
    	<cfargument name="obj"    type="any" required="true" hint="The object to evaluate"/>
		<cfargument name="family" type="string" required="true" default="" hint="The family string to check"/>
    	<cfscript>
    		var md 			= "";
			var moreChecks  = true;
			
    		// Get cf7 nasty metadata
			md = getMetadata(arguments.obj);
			if( NOT structKeyExists(md, "extends") ){
				return false;
			}
			md = md.extends;
			
			while(moreChecks){
				// Check inheritance family?
				if( md.name eq arguments.family){
					return true;
				}
				// Else check further inheritance?
				else if ( structKeyExists(md, "extends") ){
					md = md.extends;
				}
				else{
					return false;
				}
			}
    		
			return false;
    	</cfscript>
    </cffunction>
	
	
	<!--- isFamilyType --->
    <cffunction name="isFamilyType" output="false" access="public" returntype="boolean" hint="Checks if an object is of the passed in family type">
    	<cfargument name="family" type="string" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" type="any" 	required="true" hint="The target object"/>
		<cfscript>
			var familyPath = "";
			
			switch(arguments.family){
				case "handler" 		: { familyPath = "coldbox.system.EventHandler"; break; }
				case "plugin" 		: { familyPath = "coldbox.system.Plugin"; break; }
				case "interceptor"  : { familyPath = "coldbox.system.Interceptor"; break; }
				default:{
					throwit('Invalid family sent #arguments.family#');
				}
			}
			
			if( structKeyExists(getFunctionList(), "isInstanceOf") ){
				return isInstanceOf(arguments.target,familyPath);
			}
			else{
				return isInstanceCheck(arguments.target,familyPath);
			}
		</cfscript>		
    </cffunction>
	
	<!--- convertToColdBox --->
    <cffunction name="convertToColdBox" output="false" access="public" returntype="void" hint="Decorate an object as a ColdBox object">
    	<cfargument name="family" type="string" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" type="any" 	required="true" hint="The target object"/>
		<cfscript>
			var baseObject = "";
			var familyPath = "";
			var key 	   = "";
			
			switch(arguments.family){
				case "handler" 		: { familyPath = "coldbox.system.EventHandler"; break; }
				case "plugin" 		: { familyPath = "coldbox.system.Plugin"; break; }
				case "interceptor"  : { familyPath = "coldbox.system.Interceptor"; break; }
				default:{
					throwit('Invalid family sent #arguments.family#');
				}
			}
			
			// Mix it up baby
			arguments.target.$injectUDF = this.injectUDFMixin;
			
			// Create base family object
			baseObject = createObject("component",familyPath);
			
			// Check if init already exists?
			if( structKeyExists(arguments.target, "init") ){ arguments.target.$cbInit = baseObject.init;	}	
			
			// Mix in methods
			for(key in baseObject){
				// If handler has overriden method, then don't override it with mixin, simulated inheritance
				if( NOT structKeyExists(arguments.target, key) ){
					arguments.target.$injectUDF(key,baseObject[key]);
				}
			}
			
			// Mix in fake super class
			arguments.target.$super = baseObject;
		</cfscript>
    </cffunction>
	
	<!--- arrayToStruct --->
	<cffunction name="arrayToStruct" output="false" access="public" returntype="struct" hint="Convert an array to struct argument notation">
		<cfargument name="in" type="array" required="true" hint="The array to convert"/>
		<cfscript>
			var results = structnew();
			var x       = 1;
			
			for(x=1; x lte Arraylen(arguments.in); x=x+1){
				results[x] = arguments.in[x];
			}
			
			return results;
		</cfscript>
	</cffunction>

</cfcomponent>