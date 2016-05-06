@startuml
!includeurl https://raw.githubusercontent.com/w3c/webpayments-flows/gh-pages/PaymentFlows/skin.ipml

Participant "Payee (Merchant) PSP [Acquirer]" as MPSP
Participant "Payee (Merchant) [Acceptor] Website" as Payee
participant "Payer's (Shopper's) Browser" as UA
Actor "Payer [Cardholder]" as Payer
participant "UnionPay Bank [Issuer]" as CPSP

note over Payee, Payer: HTTPS

title Merchant Hosted UnionPay Payment (http://www.asiapaytech.com/banks/union-online-payment-option-for-banks.html) (Current)

== Negotiation of Payment Terms  & Selection of Payment Instrument ==

Payee->UA: Present Check-out page 
Payer<-[#green]>UA: Select Checkout with Card
Payer<-[#green]>UA: Select UnionPay Brand (Credit or Debit)
Payer<-[#green]>UA: Payer Fills Form (PAN, [Name], [Expiry], [CSC], [Billing Address], [MobilePhoneNo])
Note right: May be auto-filled from browser 

== Payment Processing ==

Alt
	UA->Payee: payload
Else
	UA->Payee: Encrypt(payload)
	Note right: Custom code on merchant webpage can encrypt payload to reduce PCI burden from SAQ D to SAQ A-EP
End

opt
	Payee->Payee: Store Card
	note right: Merchant can store card details (apart from CSC) (even if encrypted) for future use (a.k.a. Card on File)
end


Payee-\MPSP: Authorise (payload)

Group Optional Secondary Authentication
	MPSP<->CPSP: Send Authorisation SMS (PAN, [Name], [Expiry], [CSC], [Billing Address], MobilePhoneNo)

	MPSP->Payee: SMS Authcode request
	Payee->UA: SMS Authcode request

	...
	
	CPSP-[#black]>Payer: 6 Digit Numeric Authorisation code (via SMS)
	Payer<-[#green]>UA: Payer Fills Form (AuthCode)	
	
	UA->Payee: payload including AuthCode
	Payee-\MPSP: Authorise (payload including AuthCode)

End

MPSP-\CPSP: Authorisation Request
CPSP-/MPSP: Authorisation Response

MPSP-/Payee: Authorisation Result

== Notification ==

Payee->UA: Result Page

...

== Payment Processing Continued: Request for Settlement process (could be immediate, batch (e.g. daily) or after some days) ==

Alt
	Payee -> MPSP : Capture
	note right: Later Capture may be called, for example after good shipped or tickets pickedup
Else
	MPSP -> MPSP : Auto Capture in batch processing at end-of-day
End	
	
MPSP->CPSP: Capture

...

== Delivery of Product ==

Payee->Payer: Provide products or services


@enduml
