<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	General handler for my hello application. Please remember to alter
	your extends base component using the Coldfusion Mapping.

	example:
		Mapping: fwsample
		Argument Type: fwsample.system.EventHandler
Modification History:
Sep/25/2005 - Luis Majano
	-Created the template.
----------------------------------------------------------------------->
<cfcomponent name="baseHandler" output="false">

<!--- Autowire --->
<cfproperty name="badService" type="ioc" scope="instance">

	<cffunction name="doColdboxFactoryTests" access="public" returntype="any" hint="" output="false" >
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfscript>
		var rc = event.getCollection();
		
		rc.testModel = getPlugin("IOC").getBean("testModel");
		
		event.setView("coldboxfactory");
		</cfscript>
	</cffunction>

</cfcomponent>