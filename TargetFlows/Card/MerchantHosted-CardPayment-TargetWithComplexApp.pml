@startuml
!includeurl https://raw.githubusercontent.com/w3c/webpayments-flows/gh-pages/PaymentFlows/skin.ipml

Participant "Payee (Merchant) PSP [Acquirer]" as MPSP
Participant "Payee (Merchant) [Acceptor] Website" as Payee
participant "Payer's (Shopper's) Browser" as UA
Actor "Payer [Cardholder]" as Payer

participant "Payment Mediator" as UAM
participant "Payment App" as PSPUI

participant "Issuing Bank [Issuer]" as CPSP

note over Payee, PSPUI: HTTPS

title Merchant Hosted Card Payment with Acquirer/Scheme/Issuer supplier Payment Application (Target)

== Negotiation of Payment Terms  & Selection of Payment Instrument ==

Payee->UA: Present Check-out page 
Payer<-[#green]>UA: Select Checkout
Payer<-[#green]>Payee: Establish Payment Obligation (including delivery obligations)
Payee->UA: Payment and delivery details

UA->UAM: PaymentRequest (Items, Amounts, Shipping Options )
note right #aqua: PaymentRequest.Show()
opt
	Payer<-[#green]>UAM: Select Shipping Options	
	UAM->UA: Shipping Info
	note right #aqua: shippingoptionchange or shippingaddresschange events

	UA->UAM: Revised PaymentRequest
end
Payer<-[#green]>UAM: Select <b><color:red>Card</color></b> Payment Instrument

UAM<-[#green]>PSPUI: Invoke <b><color:red>Card</color></b> Payment App (Instrument)

UAM->PSPUI: PaymentRequest without Shipping Options

Payer<-[#green]>PSPUI: Authorise

== Authorisation ==

Note over UAM: Authorisation can be complex and include stronger authentication such as 3DS or alternatives as prescribed by PSD2
	PSPUI-\MPSP: Authorise (payload)
	MPSP<->CPSP: Authorisation Request/Response
	MPSP-/PSPUI: Authorisation Result	
	
	PSPUI->UAM: <b><color:red>Payment Token</color></b>

UAM->UA: <b><color:red>Payment Token</color></b>

Note Right #aqua: Show() Promise Resolves 


== Payment Processing ==

	UA->Payee: <b><color:red>Payment Token</color></b>

opt
	Payee->Payee: <b><color:red>Store Token</color></b>
	note right: Merchant can store card details if it is a reusable token <b>however PaymentRequest message will need to support this<b>
end

	Payee-> UA: <b><color:red>Token Stored Successfully</color></b>

== Notification ==

UA->UAM: Payment Completetion Status

note over UAM #aqua: response.complete(status)

UAM->UA: UI Removed

note over UAM #aqua: complete promise resolves

UA->UA: Navigate to Result Page

== Payment Processing Continued: Request for Settlement process (could be immediate, batch (e.g. daily) or after some days) ==

Alt
	Payee -> MPSP : Capture
	note right: Later Capture may be called, for example after good shipped or tickets pickedup
Else
	MPSP -> MPSP : Auto Capture in batch processing at end-of-day
End	
	
MPSP->CPSP: Capture

== Delivery of Product ==

Payee->Payer: Provide products or services


@enduml
