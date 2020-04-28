
<!--- Start Data related to call ---->
<cfset stripe_api_key = 'sk_Stripe_API_Key_Here' />
<cfset stripe_api_url = 'https://api.stripe.com/v1/' />
<!--- End Data related to call ---->

<cfset customer_name = '' />
<cfset customer_email = '' />
<cfset customer_description = '' />
<cfset customer_phone = '' />

<!--- Start Data related to card object --->
<!--- These are required --->
	<cfset currency = 'usd' />
	<cfset card_data['number'] = '4242424242424242' />
	<cfset card_data['exp_month'] = '#MO#' />
	<cfset card_data['exp_year'] = '#YR#' />
	<cfset card_data['cvc'] = '#form.cvc#' />
	
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
	
	<cfset amount = 1.00 />	
   
    <cfset description = 'SomeDescription' />  

<!---  create card for customer --->
<cfset token_data = createToken(card = card_data) />

<cfif structKeyExists(token_data,'error')>
	<cfset token_error = token_data.error.message />
<cfelse>

	<cfset card_token = token_data.id />
	<!--- Here we are going to create customer --->
	<cfset customer_data = createCustomer(card=card_token, name=customer_name, email=customer_email, description=customer_description, phone=customer_phone, plan='', coupon='') />
	
	<cfif structKeyExists(customer_data,'error')>
		<cfset errormessage = token_data.error.message />
	<cfelse>
		
		<cfset customer_id = customer_data.id /> <!--- This is the customer id --->
		<!--- Here we are going to create charge against customer --->
		<cfset charge_data = createCharge(amount = amount, customer_id = customer_id, description = description) />
		
		<cfif structKeyExists(charge_data,'error')>
			<cfset errormessage = charge_data.error.message />
		<cfelse>
			<cfset response = 'Approved' />
		</cfif>				

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

<cffunction name="createCustomer" access="private">
	<cfargument name="card" default="" required="true">
	<cfargument name="name" default="" required="true">
	<cfargument name="email" default="" required="true">
	<cfargument name="description" default="" required="true">
	<cfargument name="phone" default="" required="true">
	<cfargument name="plan" default="" required="true">
	<cfargument name="coupon" default="" required="true">
	
	<cfhttp url="#stripe_api_url#customers" method="POST" username="#stripe_api_key#" password="" charset="utf-8" result="customer_result">
		
		<cfif Len(Trim(arguments.card))>
			<cfhttpparam type="formfield" name="card" value="#Trim(arguments.card)#" >
		</cfif>
		
		<cfif Len(Trim(arguments.coupon))>
			<cfhttpparam type="formfield" name="coupon" value="#Trim(arguments.coupon)#" >
		</cfif>
		<cfif Len(Trim(arguments.email))>
			<cfhttpparam type="formfield" name="email" value="#Trim(arguments.email)#" >
		</cfif>
		<cfif Len(Trim(arguments.name))>
			<cfhttpparam type="formfield" name="name" value="#Trim(arguments.name)#" >
		</cfif>
		<cfif Len(Trim(arguments.description))>
			<cfhttpparam type="formfield" name="description" value="#Trim(arguments.description)#" >
		</cfif>
		<cfif Len(Trim(arguments.plan))>
			<cfhttpparam type="formfield" name="plan" value="#Trim(arguments.plan)#" >
		</cfif>
		<cfif Len(Trim(arguments.phone))>
			<cfhttpparam type="formfield" name="phone" value="#Trim(arguments.phone)#" >
		</cfif>
		
	</cfhttp>
	
	<cfif NOT isDefined("customer_result.statusCode")>
		<cfthrow type='Stripe' errorcode="stripe_unresponsive" message="The Stripe server did not respond." detail="The Stripe server did not respond." />
	<cfelseif left(customer_result.statusCode,3) NEQ "200">
		<cfreturn deserializeJSON(customer_result.filecontent) />
	</cfif>
	
	<cfreturn deserializeJSON(customer_result.filecontent) />
	
</cffunction>

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