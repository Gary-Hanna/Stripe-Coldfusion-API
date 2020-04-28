# Stripe-Coldfusion-API
Process credit card charges with Stripe in Coldfusion. Optional store card for future use.
Charge_no_save.cfm processes the payment but does not create a Stripe Customer to store the credit card.
Charge_save.cfm processes the payment and creates a Stripe Customer to store the card for future transactions.
Create_customer.cfm creates a Stripe Customer and stores the card for future transactions without a sale.
Customer_chage.cfm charges an existing customer by passing the stripe Customer Token without the card data.
Customer_udpate.cfm updates the address and card of a Stripe Customer record for future transactions.

Requires a Stripe.com API key and account
