

<!--- Stripe Processing --->
	<cfset stripe_api_key = 'sk_Stripe_API_Key_Here' /> 
	<cfset stripe_api_url = 'https://api.stripe.com/v1/' />
	
	<!--- These are required --->
	<cfset currency = 'usd' />
	<cfset card_data['number'] = '4242424242424242' />
	<cfset card_data['exp_month'] = '01' />
	<cfset card_data['exp_year'] = '23' />
	<cfset card_data['cvc'] = '123' />
	
	<!--- These are optional --->
	<cfset card_data['name'] = 'Gary Hanna' />
	<cfset card_data['address_line1'] = '123 Main Street' />
	<cfset card_data['address_line2'] = '' />
	<cfset card_data['address_zip'] = '01532' />
	<cfset card_data['address_state'] = 'MA' />
	<cfset card_data['address_city'] = 'Northborough' />
	<cfset card_data['address_country'] = 'USA' />
	
	<cfset amount = 1.00/>	
   
    <cfset description = 'SomeDescription' />    
    
	<cfset token_data = createToken(card = card_data) />
	
	<cfif structKeyExists(token_data,'error')>
		<cfset card_error = token_data.error.message />
	<cfelse>
		<cfset card_token = token_data.id />
		<cfset charge_data = createCharge(amount = amount, card = card_token, description = description) />
		
		<cfif structKeyExists(charge_data,'error')>
			<cfset errormessage = "#charge_data.error.message#">
		<cfelse>
			<cfset response = "Approved" />
		</cfif>	
		</cfif>		
			
	<cffunction name="createToken" access="private">
		<cfargument name="card" type="struct" required="true">
		
		<cfhttp url="#stripe_api_url#tokens" method="POST" username="#stripe_api_key#" password="" charset="utf-8" result="token_result">
			<cfhttpparam type="formfield" name="card[number]" value="#arguments.card.number#" >
			<cfhttpparam type="formfield" name="card[exp_month]" value="#arguments.card.exp_month#" >
			<cfhttpparam type="formfield" name="card[exp_year]" value="#arguments.card.exp_year#" >
			<cfhttpparam type="formfield" name="card[cvc]" value="#arguments.card.cvc#" >
			<cfif Len(Trim(arguments.card.name))>
				<cfhttpparam type="formfield" name="card[name]" value="#arguments.card.name#" >
			</cfif>
			<cfif Len(Trim(arguments.card.address_line1))>
				<cfhttpparam type="formfield" name="card[address_line1]" value="#arguments.card.address_line1#" >
			</cfif>
			<cfif Len(Trim(arguments.card.address_line2))>
				<cfhttpparam type="formfield" name="card[address_line2]" value="#arguments.card.address_line2#" >
			</cfif>
			<cfif Len(Trim(arguments.card.address_zip))>
				<cfhttpparam type="formfield" name="card[address_zip]" value="#arguments.card.address_zip#" >
			</cfif>
			<cfif Len(Trim(arguments.card.address_state))>
				<cfhttpparam type="formfield" name="card[address_state]" value="#arguments.card.address_state#" >
			</cfif>
			<cfif Len(Trim(arguments.card.address_country))>
				<cfhttpparam type="formfield" name="card[address_country]" value="#arguments.card.address_country#" >
			</cfif>
			<cfif Len(Trim(arguments.card.address_city))>
				<cfhttpparam type="formfield" name="card[address_city]" value="#arguments.card.address_city#" >
			</cfif>
			
			<cfhttpparam type="formfield" name="currency" value="#currency#" >
		</cfhttp>
		
		<cfif NOT isDefined("token_result.statusCode")>
			<cfthrow type='Stripe' errorcode="stripe_unresponsive" message="The Stripe server did not respond." detail="The Stripe server did not respond." />
		<cfelseif left(token_result.statusCode,3) NEQ "200">
			<cfreturn deserializeJSON(token_result.filecontent) />
		</cfif>
		
	   <cfreturn deserializeJSON(token_result.filecontent) /> 
	 
	</cffunction>
	
	<cffunction name="createCharge" access="private">
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="card" type="any" required="true">
		<cfargument name="description" type="string" required="true" default="">
		
		<cfhttp url="#stripe_api_url#charges" method="POST" username="#stripe_api_key#" password="" charset="utf-8" result="charge_result">
			<cfhttpparam type="formfield" name="amount" value="#arguments.amount*100#" >
			<cfhttpparam type="formfield" name="card" value="#arguments.card#" >
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