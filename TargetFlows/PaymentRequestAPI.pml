@startuml
!includeurl https://raw.githubusercontent.com/w3c/webpayments-flows/gh-pages/PaymentFlows/skin.ipml

participant "Payment Processor" as MPSP
Participant "Payee Website" as Payee
participant "Payer's (Shopper's) Browser" as UA
Actor "Payer" as Payer
participant "Payment Mediator" as UAM
participant "Payment App" as PSPUI
participant "Payment Provider" as CPSP

note over Payee, PSPUI: HTTPS

title Generic Payment Request API Flow V1

== Negotiation of Payment Terms & Selection of Payment Instrument ==

Payee->UA: Present Checkout page 
Payer<-[#green]>UA: Select Checkout
Payer<-[#green]>Payee: Establish Payment Obligation (including delivery)
Payee->UA: Payment & delivery details

UA->UAM: PaymentRequest (Items, Amounts, Shipping Options )
note right #aqua: PaymentRequest.Show() 
opt
	Payer<-[#green]>UAM: Select Shipping Options	
	UAM->UA: Shipping Info
	note right #aqua: shippingoptionchange or shippingaddresschange events

	UA->UAM: Revised PaymentRequest
end
Payer<-[#green]>UAM: Select Payment Instrument

UAM<-[#green]>PSPUI: Invoke Payment App

UAM->PSPUI: PaymentRequest (- Options)

Payer<-[#green]>PSPUI: Authorise

Group Method specific processing
	PSPUI<->CPSP: interaction(s)
		note left
		(e.g. Authorise Payment
		/ Tokenise Payment Instrument)
		end note
end

PSPUI->UAM: Payment App Response


UAM->UA: Payment App Response

Note Right #aqua: Show() Promise Resolves 

== Payment Processing ==

UA-\Payee: Payment App Response

opt
	Payee-\MPSP: Finalise Payment
	MPSP-\CPSP: Finalise Payment
	CPSP-/MPSP: Payment Response
	MPSP-/Payee: Payment Response
end
	
== Notification ==

UA->UAM: Payment Completetion Status

note over UAM #aqua: response.complete(status)

UAM->UA: UI Removed

note over UAM #aqua: complete promise resolves

UA->UA: Navigate to Result Page

== Payment Processing Continued ==

opt
	Payee-\MPSP: Finalise Payment
	MPSP-\CPSP: Finalise Payment
	CPSP-/MPSP: Payment Response
	MPSP-/Payee: Payment Response
end
	

== Delivery of Product ==

Payee->Payer: Provide products or services

@enduml