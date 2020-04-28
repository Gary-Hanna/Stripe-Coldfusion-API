	<cfset MO = Left("#Form.expiry#",2)>
	<cfset YR = Right("#Form.expiry#",2)>

		<!--- Start Data related to call ---->
<cfset stripe_api_key = 'sk_Stripe_API_Key_Here' />
<cfset stripe_api_url = 'https://api.stripe.com/v1/' />
<cfset currency = 'usd' />

<cfset customer_id = 'Customer_ID From Stripe Goes Here' />


<!--- Start Data related to charge object --->
<cfset amount = 1.00 />	
<cfset description = '' />
<!--- End Data related to charge object --->

<cfset charge_data = createCharge(amount = amount, customer_id = customer_id, description = description) />
		
<cfif structKeyExists(charge_data,'error')>
	<cfset errormessage = '#charge_data.error.message#' />
<cfelse>
    <cfset response = 'Approved' />
</cfif>

<cffunction name="createCharge" access="private">
	<cfargument name="amount" type="numeric" required="true">
	<cfargument name="customer_id" type="any" required="true">
	<cfargument name="description" type="string" required="true" default="">
	
	<cfhttp url="#stripe_api_url#charges" method="POST" username="#stripe_api_key#" password="" charset="utf-8" result="charge_result">
		<cfhttpparam type="formfield" name="amount" value="#arguments.amount*100#" >
		<cfhttpparam type="formfield" name="customer" value="#arguments.customer_id#" >
		<cfhttpparam type="formfield" name="description" value="#arguments.description#" >
		<cfhttpparam type="formfield" name="currency" value="#currency#" >
	</cfhttp>
	
	<cfif NOT isDefined("charge_result.statusCode")>
		<cfthrow type='Stripe' errorcode="stripe_unresponsive" message="The Stripe server did not respond." detail="The Stripe server did not respond." />
	<cfelseif left(charge_result.statusCode,3) NEQ "200">
		<cfreturn deserializeJSON(charge_result.filecontent) />
	</cfif>
	
	<cfreturn deserializeJSON(charge_result.filecontent) />
	
</cffunction>